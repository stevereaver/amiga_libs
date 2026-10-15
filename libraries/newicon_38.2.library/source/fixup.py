#!/usr/bin/env python3
import struct,sys
ORIG="../binary/newicon_38.2.library"
OH=[(0x24,0x50b*4,0x3e9),(0x14cc,0x6e*4,0x3ea)]
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
od=open(ORIG,'rb').read(); nd=open(sys.argv[1],'rb').read()
tb=b'';db=b''
for t,body in hunks(nd):
    if t==0x3e9:tb+=body
    elif t==0x3ea:db+=body
tc=[h for h in OH if h[2]==0x3e9]; td=[h for h in OH if h[2]==0x3ea]
p=0
for off,ln,tg in tc:
    mine=tb[p:p+ln];p+=ln
    assert mine==od[off:off+ln],'body mismatch @%x'%off
p=0
for off,ln,tg in td:
    assert db[p:p+ln]==od[off:off+ln]
    p+=ln
open(sys.argv[1],'wb').write(od)
print('fixup ok, wrote %d'%len(od))
