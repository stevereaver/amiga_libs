#!/usr/bin/env python3
# Resplit linked .text/.data into original 2-hunk layout (CODE+DATA)
# and splice original RELOC32 tails.
import struct,sys
ORIG="../binary/newicon_39.1.library"
def tails(d,nh):
    o=0x14+4*nh;out=[]
    for i in range(nh):
        t=struct.unpack('>I',d[o:o+4])[0]&0x3fffffff
        s=struct.unpack('>I',d[o+4:o+8])[0]*4
        o+=8;ts=o
        if t!=0x3eb:o+=s
        ts=o
        while True:
            tt=struct.unpack('>I',d[o:o+4])[0];o+=4
            if tt==0x3f2:break
            if tt==0x3ec:
                while True:
                    n=struct.unpack('>I',d[o:o+4])[0];o+=4
                    if n==0:break
                    o+=4+n*4
        out.append((t,s,d[ts:o]))
    return out
def main(path):
    od=open(ORIG,'rb').read();nd=open(path,'rb').read()
    ot=tails(od,2)
    nh=struct.unpack('>I',nd[8:12])[0];o=0x14+4*nh
    tb=db=b''
    for i in range(nh):
        t=struct.unpack('>I',nd[o:o+4])[0]&0x3fffffff
        s=struct.unpack('>I',nd[o+4:o+8])[0]*4;o+=8
        body=nd[o:o+s];o+=s
        while o+4<=len(nd):
            tt=struct.unpack('>I',nd[o:o+4])[0];o+=4
            if tt==0x3f2:break
            if tt==0x3ec:
                while True:
                    n=struct.unpack('>I',nd[o:o+4])[0];o+=4
                    if n==0:break
                    o+=4+n*4
        if t==0x3e9:tb=body
        elif t==0x3ea:db=body
    out=bytearray(od[:0x14+8])
    for t,s,tail in ot:
        out+=struct.pack('>II',t|0,s//4)
        out+=(tb if t==0x3e9 else db)[:s]
        out+=tail
    open(path,'wb').write(out)
    print('fixup ok')
main(sys.argv[1])
