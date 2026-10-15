#!/usr/bin/env python3
# Rebuild muihelp 19.9's 3-hunk file (CODE, DATA, DATA|0x40000000)
# splicing original tails (RELOC32 groups + END) back onto the
# linked bodies. Hunks are matched by index (two DATA hunks would
# collide in a type-keyed map). Hunk 2 is a flagged DATA hunk whose
# body is 24 zero bytes; the linker emits it as a body-less BSS
# hunk, so the original body is spliced back in.
import struct,sys
ORIG="../binary/muihelp_19.9.library"
def hunks(d):
    n=struct.unpack('>I',d[0x10:0x14])[0]+1
    o=0x14+4*n; out=[]
    for _ in range(n):
        t,s=struct.unpack('>II',d[o:o+8]); o+=8
        b=o
        if (t&0x3fffffff)!=0x3eb: o+=s*4
        ts=o
        while True:
            tt=struct.unpack('>I',d[o:o+4])[0]; o+=4
            if tt==0x3f2: break
            if (tt&0x3fffffff)==0x3ec:
                while True:
                    c=struct.unpack('>I',d[o:o+4])[0]; o+=4
                    if c==0:break
                    o+=4+c*4
            elif tt==0x3f0:
                while True:
                    nl=struct.unpack('>I',d[o:o+4])[0]; o+=4
                    if nl==0:break
                    o+=nl*4+4
        out.append((t,s*4,d[b:b+s*4] if (t&0x3fffffff)!=0x3eb else b'',d[ts:o]))
    return out
def main(path):
    od=open(ORIG,'rb').read(); nd=open(path,'rb').read()
    oh=hunks(od); nh=hunks(nd)
    assert len(oh)==len(nh), "hunk count changed"
    nb=[b for t,s,b,tl in nh]
    out=bytearray(od[:0x14+4*len(oh)])
    for i,(t,s,b,tl) in enumerate(oh):
        out+=struct.pack('>II',t,s//4)
        if s and (t&0x3fffffff)!=0x3eb:
            body=nb[i] if nb[i] else b   # bodyless new hunk (bss)->orig body
            assert len(body)>=s, "hunk %d body too small"%i
            out+=body[:s]
        out+=tl
    open(path,'wb').write(bytes(out))
main(sys.argv[1])
