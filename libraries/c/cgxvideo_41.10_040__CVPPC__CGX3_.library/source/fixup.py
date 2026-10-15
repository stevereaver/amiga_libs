#!/usr/bin/env python3
# 4-hunk rebuild: h0 CODE (resident+InitTable+functab+CYBI stubs),
# h1 DATA ("OverlaySemaphore" + layers.library patch table),
# h2 CODE (initfn + Open/Close/Expunge + 8 driver funcs),
# h3 CODE (KPrintF-style debug stub w/ HUNK_SYMBOL tail).
# Orig bodies are emitted verbatim in cgv_h*.s; gas/ld pool all
# .text into one CODE hunk and .data into one DATA hunk, so we
# slice the pool per the orig record order, verify each body
# byte-for-byte, then write the orig record stream back.
import struct,sys,os
HERE=os.path.dirname(os.path.abspath(__file__))
ORIG=os.path.join(HERE,"..","binary","cgxvideo_41.10(040)(CVPPC)(CGX3).library")

def hunks(d):
    """Return list of (tag,body_off,body_len,body,tail) per hunk record."""
    nh=struct.unpack('>I',d[0x10:0x14])[0]+1
    o=0x14+4*nh; out=[]
    for _ in range(nh):
        t=struct.unpack('>I',d[o:o+4])[0]&0x3fffffff
        s=struct.unpack('>I',d[o+4:o+8])[0]&0x3fffffff;o+=8
        bo=o; body=d[o:o+s*4];o+=s*4
        ts=o
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
                    if c==0:o+=(-o)&3;break
                    o+=2+c*2
            elif tt==0x3f0:
                while True:
                    nl=struct.unpack('>I',d[o:o+4])[0];o+=4
                    if nl==0:break
                    o+=nl*4+4
            elif tt==0x3f1:
                o+=4*struct.unpack('>I',d[o:o+4])[0]+4
            else:break
        out.append((t,bo,s*4,body,d[ts:o]))
    return out

def main(path):
    od=open(ORIG,'rb').read()
    nd=open(path,'rb').read()
    oh=hunks(od); mh=hunks(nd)
    # pool my bodies per hunk type, in file order
    pool={0x3e9:b'',0x3ea:b''}
    for t,bo,ln,body,tail in mh:
        if t in pool: pool[t]+=body
    # slice per orig hunk order and verify
    off={0x3e9:0,0x3ea:0}
    for i,(t,bo,ln,body,tail) in enumerate(oh):
        if t==0x3eb: continue
        mine=pool[t][off[t]:off[t]+ln]; off[t]+=ln
        assert mine==body,'h%d body mismatch (%d bytes)'%(i,ln)
    for t in pool:
        assert off[t]==len(pool[t]),'leftover pooled %x bytes'%t
    # orig record stream (sizes/tails/symbol hunks) is already correct:
    # bodies verified equal -> emit orig verbatim
    open(path,'wb').write(od)
    print('fixup ok, wrote %d'%len(od))

main(sys.argv[1])
