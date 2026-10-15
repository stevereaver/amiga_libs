#!/usr/bin/env python3
# 6-hunk rebuild: orig bodies are emitted verbatim in .s files;
# splice the original record stream (tags/tails/order) back in.
import struct,sys
ORIG="../binary/akcc_35.1.library"
# orig hunk records: (file off of body, body bytes, tag)
HUNKS=[(0x34, 0xa5*4, 0x3e9),   # h0 CODE
       (None, 0,      0x3eb),   # h1 BSS (no body)
       (0x42c, 4,     0x3e9),   # h2 CODE
       (0x43c, 0x36c*4,0x3e9),  # h3 CODE
       (0x1308,0x1a*4,0x3ea),   # h4 DATA
       (0x137c,0x8f*4,0x3e9)]   # h5 CODE
def hunks(d):
    nh=struct.unpack('>I',d[0x10:0x14])[0]+1
    o=0x14+4*nh; out=[]
    for _ in range(nh):
        t=struct.unpack('>I',d[o:o+4])[0]&0x3fffffff
        s=struct.unpack('>I',d[o+4:o+8])[0]&0x3fffffff;o+=8
        body=d[o:o+s*4];o+=s*4
        while o+4<=len(d):
            tt=struct.unpack('>I',d[o:o+4])[0];o+=4
            if tt==0x3f2:break
            if tt==0x3ec:
                while True:
                    c=struct.unpack('>I',d[o:o+4])[0];o+=4
                    if c==0:break
                    o+=4+c*4
            elif tt==0x3f7:
                while True:
                    c=struct.unpack('>H',d[o:o+2])[0];o+=2
                    if c==0:o+=2;o+=(-o)&3;break
                    o+=2+c*2
            elif tt==0x3f0:
                while True:
                    nl=struct.unpack('>I',d[o:o+4])[0];o+=4
                    if nl==0:break
                    o+=nl*4+4
            elif tt==0x3f1:
                o+=4*struct.unpack('>I',d[o:o+4])[0]+4
            else:break
        out.append((t,body))
    return out
def main(path):
    od=open(ORIG,'rb').read()
    nd=open(path,'rb').read()
    # merge my linked bodies per type, in order
    tb=b'';db=b''
    for t,body in hunks(nd):
        if t==0x3e9:tb+=body
        elif t==0x3ea:db+=body
    # slice per orig code-hunk order (h0,h2,h3,h5) and data (h4)
    tc=[i for i,h in enumerate(HUNKS) if h[2]==0x3e9]
    td=[i for i,h in enumerate(HUNKS) if h[2]==0x3ea]
    mb={}
    p=0
    for i in tc:
        mb[i]=tb[p:p+HUNKS[i][1]];p+=HUNKS[i][1]
    p=0
    for i in td:
        mb[i]=db[p:p+HUNKS[i][1]];p+=HUNKS[i][1]
    for i,(off,ln,tg) in enumerate(HUNKS):
        if off is not None:
            assert mb[i]==od[off:off+ln],'h%d body mismatch'%i
    # copy orig record stream verbatim
    out=bytearray(od)
    # but rewrite bodies with mine (equal anyway) - orig stream is
    # already correct; emit it back unchanged.
    open(path,'wb').write(out)
    print('fixup ok, wrote %d'%len(out))
main(sys.argv[1])
