#!/usr/bin/env python3
# Post-link fixup for f1gp.library:
#  - header hunk table must declare hunk1 = 49 longs (196B alloc)
#    while the DATA hunk body holds only 26 longs (104B); the tail
#    is uninitialised (init clears it at runtime).
#  - the original linker's RELOC32 lists use a non-sorted order;
#    rewrite them to match the shipped binary exactly.
import struct, sys

path = sys.argv[1]
d = bytearray(open(path, 'rb').read())

assert d[0:4] == b'\x00\x00\x03\xf3'
names = struct.unpack('>I', d[4:8])[0]
sztab = 0x8 + 4*names + 0xc          # hunk-size table start
nh = struct.unpack('>I', d[0x10:0x14])[0] - struct.unpack('>I', d[0xc:0x10])[0] + 1
assert nh == 2, nh
h1off = sztab + 4                    # second entry
h1sz = struct.unpack('>I', d[h1off:h1off+4])[0] & 0x3fffffff
assert h1sz == 26, h1sz
struct.pack_into('>I', d, h1off, 49)

# original reloc orders (code-hunk offsets)
ORD_H0 = [0x6,0xa,0x12,0x16,0x1a,0xa6,0xae,0xf4,0xee,0x12e,
          0x1b4,0x1b8,0x1bc,0x1c0,0x1c4,0x1c8,0x1cc,0x1d0,0x210,0x22c]
ORD_H1 = [0xe8,0x78,0x142,0x19a,0x28a,0x1e0,0x68a,0x3e4,0x3a2,0x34e]

# find hunk0's RELOC32 (right after hunk0 body)
h0sz = struct.unpack('>I', d[sztab:sztab+4])[0] & 0x3fffffff
o = sztab + 4*nh                    # first hunk tag
o += 8 + h0sz*4                     # skip tag+size+body
assert struct.unpack('>I', d[o:o+4])[0] == 0x3ec, hex(o)
o += 4
lists = {}
pos = o
while True:
    n = struct.unpack('>I', d[pos:pos+4])[0]
    if n == 0:
        pos += 4
        break
    tgt = struct.unpack('>I', d[pos+4:pos+8])[0]
    lists[tgt] = pos
    pos += 8 + 4*n
want = {0: ORD_H0, 1: ORD_H1}
for tgt, off in lists.items():
    n = struct.unpack('>I', d[off:off+4])[0]
    have = [struct.unpack('>I', d[off+8+4*i:off+12+4*i])[0] for i in range(n)]
    assert sorted(have) == sorted(want[tgt]), (tgt, have)
    for i, v in enumerate(want[tgt]):
        struct.pack_into('>I', d, off+8+4*i, v)

open(path, 'wb').write(bytes(d))
print('fixup: hunk1 alloc %d->49; relocs reordered' % h1sz)
