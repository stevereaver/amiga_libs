#!/usr/bin/env python3
# Rebuild preferences_41.2's 2-hunk file (CODE+DATA) splicing
# the original RELOC32 tails.
import struct,sys
ORIG="../binary/preferences_41.2.library"
def hunks(d):
    n=struct.unpack('>I',d[0x10:0x14])[0]+1
    o=0x14+4*n; out=[]
    for _ in range(n):
        t,s=struct.unpack('>II',d[o:o+8]); o+=8
        body=o; o+=(0 if t&0x3fffffff==0x3eb else s*4)
        ts=o
        while True:
            tt=struct.unpack('>I',d[o:o+4])[0]; o+=4
            if tt==0x3f2: break
            if tt==0x3ec:
                while True:
                    c=struct.unpack('>I',d[o:o+4])[0]; o+=4
                    if c==0:break
                    o+=4+c*4
            elif tt==0x3f0:
                while True:
                    nl=struct.unpack('>I',d[o:o+4])[0]; o+=4
                    if nl==0:break
                    o+=nl*4+4
        out.append((t,s*4,d[body:body+s*4],d[ts:o]))
    return out
def main(path):
    od=open(ORIG,'rb').read(); nd=open(path,'rb').read()
    oh=hunks(od); nh=hunks(nd)
    nb={t&0x3fffffff:b for t,s,b,tl in nh if b}
    out=bytearray(od[:0x14+4*len(oh)])
    for t,s,b,tl in oh:
        out+=struct.pack('>II',t,s//4)
        if s: out+=nb[t&0x3fffffff]
        out+=tl
    open(path,'wb').write(bytes(out))
main(sys.argv[1])
