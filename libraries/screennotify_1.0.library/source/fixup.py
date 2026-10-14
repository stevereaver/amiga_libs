#!/usr/bin/env python3
# Post-link fixup for screennotify.library:
#  - header hunk table must declare hunk1 = 6 longs (24B alloc)
#    while the DATA hunk body holds only 2 longs (8B); the tail
#    is uninitialised (globals: SysBase, LibBase, saved vectors).
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
assert h1sz == 2, h1sz
struct.pack_into('>I', d, h1off, 6)

# original reloc orders (code-hunk offsets)
ORD_H0 = [0x4a,0x46,0x52,0x56,0x5a,0x5e,0x62,0x66,0x6a,0x6e,
          0x72,0x76,0x7a,0x7e,0x82]
ORD_H1 = [0x21c,0x1de,0x196,0xd2,0x5ba,0x57a,0x4ce,0x2ba,0x90a,
          0x8e2,0x8bc,0x894,0x86e,0x83e]

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
    lists.setdefault(tgt, []).append(pos)
    pos += 8 + 4*n
want = {0: ORD_H0, 1: ORD_H1}
for tgt, offs in lists.items():
    off = offs[0]
    n = struct.unpack('>I', d[off:off+4])[0]
    have = [struct.unpack('>I', d[off+8+4*i:off+12+4*i])[0] for i in range(n)]
    assert sorted(have) == sorted(want[tgt]), (tgt, have)
    for i, v in enumerate(want[tgt]):
        struct.pack_into('>I', d, off+8+4*i, v)

open(path, 'wb').write(bytes(d))
print('fixup: hunk1 alloc %d->6; relocs reordered' % h1sz)
