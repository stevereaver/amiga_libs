#!/usr/bin/env python3
# Split merged .text back into quicklayers' two CODE hunks and
# splice original tails.
import struct,sys
ORIG="../binary/quicklayers_0.55(020+).library"
HSZ=[0x2e8,0x3e5*4]
def hunks(d):
    n=struct.unpack('>I',d[0x10:0x14])[0]+1
    o=0x14+4*n; out=[]
    for _ in range(n):
        t,s=struct.unpack('>II',d[o:o+8]); o+=8
        b=o; o+=(0 if t&0x3fffffff==0x3eb else s*4)
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
        out.append((t,s*4,d[b:b+s*4],d[ts:o]))
    return out
def main(path):
    od=open(ORIG,'rb').read(); nd=open(path,'rb').read()
    oh=hunks(od); nh=hunks(nd)
    txt=nh[0][2]  # linked file: single hunk = merged .text
    out=bytearray(od[:0x14+4*len(oh)])
    off=0
    for t,s,b,tl in oh:
        out+=struct.pack('>II',t,s//4)
        out+=txt[off:off+s]
        off+=s
        out+=tl
    open(path,'wb').write(bytes(out))
main(sys.argv[1])
