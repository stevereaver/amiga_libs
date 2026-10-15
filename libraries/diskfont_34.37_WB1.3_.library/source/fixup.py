#!/usr/bin/env python3
# Split the merged .text/.data back into the original 13-hunk file
# with original RELOC32 tails.
import struct,sys
ORIG="../binary/diskfont_34.37(WB1.3).library"
TEXT_H=[(0,0x270),(1,0x38),(3,0x268),(5,0x254),(7,0x3a0),(9,0xe4),(12,0x114),(13,0x68),(14,0x3c)]
DATA_H=[(2,0x10),(4,0x10),(6,0x8),(8,0x88)]
CODE_TAG=0x3e9; DATA_TAG=0x3ea
def tails(d,nh):
    o=0x14+4*nh; out=[]
    for i in range(nh):
        t=struct.unpack('>I',d[o:o+4])[0]&0x3fffffff
        s=struct.unpack('>I',d[o+4:o+8])[0]*4
        st=o
        o+=8
        if t!=0x3eb: o+=s
        ts=o
        while True:
            tt=struct.unpack('>I',d[o:o+4])[0]; o+=4
            if tt==0x3f2: break
            if tt==0x3ec:
                while True:
                    n=struct.unpack('>I',d[o:o+4])[0]; o+=4
                    if n==0:break
                    o+=4+n*4
        out.append((t,s,d[ts:o]))
    return out
def main(path):
    od=open(ORIG,'rb').read()
    nd=open(path,'rb').read()
    otails=tails(od,15)
    # our built file: find our two hunks (text then data)
    nh=struct.unpack('>I',nd[8:12])[0]
    o=0x14+4*nh
    tb=db=b''
    for i in range(nh):
        t=struct.unpack('>I',nd[o:o+4])[0]&0x3fffffff
        s=struct.unpack('>I',nd[o+4:o+8])[0]*4; o+=8
        body=nd[o:o+s]; o+=s
        # skip our tails
        while o+4<=len(nd):
            tt=struct.unpack('>I',nd[o:o+4])[0]; o+=4
            if tt==0x3f2: break
            if tt==0x3ec:
                while True:
                    n=struct.unpack('>I',nd[o:o+4])[0]; o+=4
                    if n==0:break
                    o+=4+n*4
        if t==0x3e9 and not tb: tb=body
        elif t==0x3ea: db=body
    out=bytearray()
    out+=od[:0x14+4*15]            # original header
    for i,(t,s,tail) in enumerate(otails):
        out+=struct.pack('>II',t|0,s//4)
        if t==0x3e9 and s:
            off=sum(x[1] for x in TEXT_H[:TEXT_H.index((i,s))])
            out+=tb[off:off+s]
        elif t==0x3ea and s:
            off=sum(x[1] for x in DATA_H[:DATA_H.index((i,s))])
            out+=db[off:off+s]
        out+=tail
    open(path,'wb').write(bytes(out))
main(sys.argv[1])
