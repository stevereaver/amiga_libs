#!/usr/bin/env python3
# Post-link fixup for asyncio.library 37.2:
#  1. rewrite hunk0 RELOC32 offset lists in the original
#     (descending, grouped-by-target) order;
#  2. turn hunk1's emitted DATA hunk (0x3ea, zero body) back into a
#     HUNK_BSS (0x3eb, no body) like the original.
import struct, sys

ORIG = [
    # hunk0: (target_hunk, offsets-in-file-order)
    [(0, [0x30, 0x2c, 0x28, 0x24, 0x20, 0x1c, 0x18, 0x14,
          0x8e, 0x8a, 0x86, 0x7e, 0x7a, 0x44, 0x3c,
          0x10, 0xc, 0x8, 0x4]),
     (1, [0x962, 0x8be, 0x620, 0x580, 0x4b8, 0x494,
          0x258, 0x1d2, 0x19c, 0xf8])],
    # hunk1: no relocs
    [],
]

d = bytearray(open(sys.argv[1], 'rb').read())
nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
o = 0x14 + 4 * nh
out = bytearray(d[:o])
for i in range(nh):
    tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
    sz  = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff; o += 4
    body = d[o:o+sz*4]; o += sz*4
    groups = ORIG[i]
    recs = bytearray()
    while True:
        t = struct.unpack('>I', d[o:o+4])[0]; o += 4
        if t == 0x3ec:                           # RELOC32
            got = []
            while True:
                n = struct.unpack('>I', d[o:o+4])[0]; o += 4
                if n == 0: break
                hn = struct.unpack('>I', d[o:o+4])[0]; o += 4
                got += [(hn, struct.unpack('>I', d[o+4*j:o+4+4*j])[0])
                        for j in range(n)]
                o += 4 * n
            assert sorted(got) == sorted(
                (h, x) for h, l in groups for x in l), (i, got)
            recs += struct.pack('>I', 0x3ec)
            for hn, offs in groups:
                recs += struct.pack('>II', len(offs), hn)
                for x in offs:
                    recs += struct.pack('>I', x)
            recs += struct.pack('>I', 0)
        elif t == 0x3f2:
            break
        else:
            raise Exception('tag %x at %x' % (t, o-4))
    if i == 1:
        # original stores hunk1 as HUNK_BSS: header + END, no body
        out += struct.pack('>II', 0x3eb, sz) + recs
    else:
        out += struct.pack('>II', tag, sz) + body + recs
    out += struct.pack('>I', 0x3f2)
if o & 1: o += 1
assert o == len(d), (o, len(d))
open(sys.argv[1], 'wb').write(out)
