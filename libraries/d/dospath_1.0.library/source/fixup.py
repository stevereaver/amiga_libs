#!/usr/bin/env python3
# Post-link fixup for dospath.library:
#  - header hunk-size table entry for hunk1 is 3 (12B alloc) although
#    its record body carries only 1 long; ld writes the section size (1)
#    so we patch the table long.
#  - rewrite hunk0's RELOC32 groups in the original order.
import struct, sys

# hunk0 reloc order: (target_hunk, [offsets])
ORIG = [
    (0, [0x40, 0x3c, 0x48, 0x4c, 0x50, 0x54, 0x58, 0x5c, 0x64, 0x60,
         0x68, 0x6c, 0x70, 0x74, 0x78, 0x7c, 0x80, 0x84]),
    (1, [0x26a, 0x1f4, 0x154, 0x112, 0x5a0, 0x630, 0x724, 0x770,
         0x85e, 0x836, 0x89e, 0x91e]),
]

d = bytearray(open(sys.argv[1], 'rb').read())
assert struct.unpack('>I', d[0:4])[0] == 0x3f3
nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
assert nh == 2
# header table: sizes at 0x14, 0x18 -- patch hunk1 to 3
assert struct.unpack('>I', d[0x18:0x1c])[0] == 1
struct.pack_into('>I', d, 0x18, 3)

o = 0x14 + 4 * nh
tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
assert tag == 0x3e9                            # hunk0 CODE
sz = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff; o += 4
assert sz == 0x268
o += sz * 4                                    # body
t = struct.unpack('>I', d[o:o+4])[0]; o += 4
assert t == 0x3ec                              # RELOC32
got = []
p0 = o
while True:
    n = struct.unpack('>I', d[o:o+4])[0]; o += 4
    if n == 0: break
    hn = struct.unpack('>I', d[o:o+4])[0]; o += 4
    got += [(hn, struct.unpack('>I', d[o+4*j:o+4+4*j])[0])
            for j in range(n)]
    o += 4 * n
assert sorted(got) == sorted(
    (h, x) for h, l in ORIG for x in l), got
o = p0
for hn, offs in ORIG:
    struct.pack_into('>I', d, o, len(offs)); o += 4
    struct.pack_into('>I', d, o, hn); o += 4
    for x in offs:
        struct.pack_into('>I', d, o, x); o += 4
struct.pack_into('>I', d, o, 0); o += 4
assert struct.unpack('>I', d[o:o+4])[0] == 0x3f2; o += 4   # END
assert struct.unpack('>I', d[o:o+4])[0] == 0x3ea; o += 4   # hunk1 DATA
assert struct.unpack('>I', d[o:o+4])[0] == 1; o += 4
o += 4
assert struct.unpack('>I', d[o:o+4])[0] == 0x3f2; o += 4   # END
assert o == len(d)
open(sys.argv[1], 'wb').write(d)
