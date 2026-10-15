#!/usr/bin/env python3
# 4 hunks: h0 CODE+h1 CODE (from concatenated .text), h2 DATA, h3 BSS.
# Splice original tails verbatim (h0's is DREL16).
import struct,sys
ORIG="../binary/ire_3.17.library"
H0S=0x4b5*4; H1S=0x27*4; H2S=0x5*4
def tails(d):
    n=struct.unpack('>I',d[8:12])[0]+1 if 0 else None
def recs(d):
    o=0x24;out=[]
    for i in range(4):
        t=struct.unpack('>I',d[o:o+4])[0]
        s=struct.unpack('>I',d[o+4:o+8])[0]&0x3fffffff
        body=o+8;pp=body+(0 if t==0x3eb else s*4);ts=pp
        while True:
            tt=struct.unpack('>I',d[pp:pp+4])[0];pp+=4
            if tt==0x3f2:break
            if tt==0x3ec:
                while True:
                    c=struct.unpack('>I',d[pp:pp+4])[0];pp+=4
                    if c==0:break
                    pp+=4+c*4
            elif tt==0x3f7:
                while True:
                    c=struct.unpack('>H',d[pp:pp+2])[0];pp+=2
                    if c==0:
                        hn_=struct.unpack('>H',d[pp:pp+2])[0];pp+=2
                        pp+=(-pp)&3
                        break
                    pp+=2+c*2
            elif tt==0x3f0:
                while True:
                    nl=struct.unpack('>I',d[pp:pp+4])[0];pp+=4
                    if nl==0:break
                    pp+=nl*4+4
            else:break
        out.append((t,s,ts,d[ts:pp]));o=pp
    return out
def main(path):
    od=open(ORIG,'rb').read();nd=open(path,'rb').read()
    orec=recs(od)
    n=struct.unpack('>I',nd[8:12])[0];o=0x14+4*n
    tb=db=b''
    for i in range(n):
        t=struct.unpack('>I',nd[o:o+4])[0]&0x3fffffff
        s=struct.unpack('>I',nd[o+4:o+8])[0]*4;o+=8
        body=nd[o:o+s];o+=s
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
                    if c==0:
                        o+=2;o+=(-o)&3;break
                    o+=2+c*2
            elif tt==0x3f0:
                while True:
                    nl=struct.unpack('>I',nd[o:o+4])[0];o+=4
                    if nl==0:break
                    o+=nl*4+4
            else:break
        if t==0x3e9:tb+=body
        elif t==0x3ea:db+=body
    out=bytearray(od[:0x24])
    for i,(t,s,ts,tail) in enumerate(orec):
        out+=struct.pack('>II',t,s)
        if t==0x3e9:
            out+=tb[:s*4]; tb=tb[s*4:]
        elif t==0x3ea:
            out+=db[:s*4]; db=db[s*4:]
        # BSS emits nothing
        out+=tail
    open(path,'wb').write(out);print('fixup ok')
main(sys.argv[1])
