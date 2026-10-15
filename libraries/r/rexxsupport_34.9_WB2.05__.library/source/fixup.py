import struct,sys
p=sys.argv[1]
d=bytearray(open(p,'rb').read())
nh=struct.unpack('>I',d[0x10:0x14])[0]+1
assert nh==1
sz=struct.unpack('>I',d[0x14:0x18])[0]
# locate code hunk record+body+tail; append empty DATA hunk record
o=0x18
t,s=struct.unpack('>II',d[o:o+8]);o+=8+s*4
while True:
    tt=struct.unpack('>I',d[o:o+4])[0]
    if tt==0x3f2:o+=4;break
    if tt==0x3ec:
        o+=4
        while True:
            c=struct.unpack('>I',d[o:o+4])[0];o+=4
            if c==0:break
            o+=4+c*4
    elif tt==0x3f0:
        o+=4
        while True:
            nl=struct.unpack('>I',d[o:o+4])[0];o+=4
            if nl==0:break
            o+=nl*4+4
    else:o+=4
tail=d[o:]
# splice original h0 tail (RELOC32 + END) replacing linker's bare END
RELOC=bytes.fromhex('000003ec0000000a00000000000000060000000a00000012000000160000001a00000024000000280000002c000000440000005600000000000003f2')
out=struct.pack('>7I',0x3f3,0,2,0,1,sz,0)+d[0x18:o-4]+RELOC+struct.pack('>3I',0x3ea,0,0x3f2)+tail
open(p,'wb').write(out)
print('fixup ok, wrote %d'%len(out))
