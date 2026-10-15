import struct,sys
ORIG='../binary/xprdmodem_2.6.library'
orig=open(ORIG,'rb').read()
b=bytearray(open(sys.argv[1],'rb').read())
def hunks(b):
    ts=struct.unpack('>L',b[0x8:0xc])[0]
    o=0x14+4*ts
    hs=[]
    while o<len(b):
        t=struct.unpack('>L',b[o:o+4])[0]
        if t not in (0x3e9,0x3ea,0x3eb):break
        sz=struct.unpack('>L',b[o+4:o+8])[0]
        body=o+8;o=body
        if t!=0x3eb:o+=sz*4
        tail=o
        while 1:
            x=struct.unpack('>L',b[o:o+4])[0];o+=4
            if x==0x3ec:
                while 1:
                    n=struct.unpack('>L',b[o:o+4])[0];o+=8
                    if n==0:o-=4;break
                    o+=4*n
            elif x==0x3f0:
                while 1:
                    n=struct.unpack('>L',b[o:o+4])[0];o+=4
                    if n==0:break
                    o+=4*n+4
            elif x==0x3f1:o+=4+4*struct.unpack('>L',b[o:o+4])[0]
            elif x==0x3f7:
                while 1:
                    n=struct.unpack('>H',b[o:o+2])[0];o+=2
                    if n==0:break
                    o+=2+2*n
                o+=(-o)&3
            elif x==0x3f2:break
            else:raise Exception('tag %x @%x'%(x,o-4))
        hs.append((t,body,tail,o))
    return hs,o
oh,oend=hunks(orig);mh,mend=hunks(b)
pool={}
for t,body,tail,te in mh:
    pool.setdefault(t,bytearray());pool[t]+=b[body:tail]
out=bytearray(orig[:oh[0][1]-8])
for t,body,tail,te in oh:
    out+=orig[body-8:body]
    if t!=0x3eb:
        olen=tail-body
        mine=bytes(pool[t][:olen]);del pool[t][:olen]
        oo=orig[body:tail]
        assert mine==oo,'hunk body mismatch'
        out+=mine
    out+=orig[tail:te]

open(sys.argv[1],'wb').write(bytes(out))
print('fixup ok, wrote',len(out))
