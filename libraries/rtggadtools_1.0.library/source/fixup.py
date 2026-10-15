#!/usr/bin/env python3
# 5-hunk rebuild: splice original record stream verbatim —
# DEBUG(0x3f1)/SYMBOL(0x3f0) records are interleaved and kept whole.
import struct,sys
ORIG="../binary/rtggadtools_1.0.library"
# orig body spans (file offsets)
BODY=[(0x30,0x3db*4),(0x1288,16),(0x12e0,0xb*4),(0x13c8,24),(0x1450,0x19*4)]
def main(path):
    od=open(ORIG,'rb').read()
    nd=open(path,'rb').read()
    # collect my linked bodies per type in order
    fh=struct.unpack('>I',nd[0xc:0x10])[0]
    lh=struct.unpack('>I',nd[0x10:0x14])[0]
    nh=lh-fh+1
    o=0x14+4*nh
    tb=db=b''
    for i in range(nh):
        t=struct.unpack('>I',nd[o:o+4])[0]&0x3fffffff
        s=struct.unpack('>I',nd[o+4:o+8])[0];o+=8
        body=nd[o:o+s*4];o+=s*4
        while o+4<=len(nd):
            tt=struct.unpack('>I',nd[o:o+4])[0];o+=4
            if tt==0x3f2:break
            if tt==0x3ec:
                while True:
                    c=struct.unpack('>I',nd[o:o+4])[0];o+=4
                    if c==0:break
                    o+=4+c*4
            elif tt==0x3f7:
                while True:
                    c=struct.unpack('>H',nd[o:o+2])[0];o+=2
                    if c==0:o+=2;o+=(-o)&3;break
                    o+=2+c*2
            elif tt==0x3f0:
                while True:
                    nl=struct.unpack('>I',nd[o:o+4])[0];o+=4
                    if nl==0:break
                    o+=nl*4+4
            elif tt==0x3f1:
                sz2=struct.unpack('>I',nd[o:o+4])[0];o+=4+sz2*4
            else:break
        if t==0x3e9:tb+=body
        elif t==0x3ea:db+=body
    # rebuild: orig header + per-hunk (tag,sz,body,tail) where body = mine
    out=bytearray(od[:0x28])
    pos=0x28; hi=0
    while hi<5 or pos<len(od):
        t=struct.unpack('>I',od[pos:pos+4])[0]
        if t in (0x3e9,0x3ea,0x3eb):
            sz=struct.unpack('>I',od[pos+4:pos+8])[0]&0x3fffffff
            bs=BODY[hi][1]
            out+=struct.pack('>II',t,sz)
            if t!=0x3eb:
                src=tb if t==0x3e9 else db
                out+=src[:bs]
                if t==0x3e9:tb=tb[bs:]
                else:db=db[bs:]
            pos+=8+(0 if t==0x3eb else sz*4)
            hi+=1
            # copy tail verbatim until next record tag or EOF
            while pos<len(od):
                tt=struct.unpack('>I',od[pos:pos+4])[0]
                if tt in (0x3e9,0x3ea,0x3eb):
                    # could be next hunk
                    break
                out+=od[pos:pos+4];pos+=4
                if tt==0x3f2:continue
                if tt==0x3ec:
                    while True:
                        c=struct.unpack('>I',od[pos:pos+4])[0];out+=od[pos:pos+4];pos+=4
                        if c==0:break
                        out+=od[pos:pos+4+c*4];pos+=4+c*4
                elif tt==0x3f0:
                    while True:
                        nl=struct.unpack('>I',od[pos:pos+4])[0];out+=od[pos:pos+4];pos+=4
                        if nl==0:break
                        out+=od[pos:pos+nl*4+4];pos+=nl*4+4
                elif tt==0x3f1:
                    sz2=struct.unpack('>I',od[pos:pos+4])[0];out+=od[pos:pos+4+sz2*4];pos+=4+sz2*4
                else:continue
        else:
            out+=od[pos:pos+4];pos+=4
    open(path,'wb').write(out)
    print('fixup ok, wrote',len(out))
main(sys.argv[1])
