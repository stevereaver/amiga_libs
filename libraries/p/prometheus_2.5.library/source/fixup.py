#!/usr/bin/env python3
# Post-link fixup for prometheus.library:
#  rewrite hunk0's RELOC32 groups in the original order:
#    7 offsets -> hunk0 (ascending), then 1 offset -> hunk1.
#  hunk1's single group (18 offsets -> hunk0) is left as-is
#  (already ascending).
import struct, sys

ORIG = [
    (0, [0x6, 0xa, 0x12, 0x16, 0x1a, 0x4fc, 0x516]),
    (1, [0x4dc]),
]

d = bytearray(open(sys.argv[1], 'rb').read())
assert struct.unpack('>I', d[0:4])[0] == 0x3f3
nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
assert nh == 2

o = 0x14 + 4 * nh
tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
assert tag == 0x3e9                            # hunk0 CODE
sz = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff; o += 4
assert sz == 0x266, hex(sz)
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
assert struct.unpack('>I', d[o:o+4])[0] == 0x13; o += 4
o += 0x4c
t = struct.unpack('>I', d[o:o+4])[0]; o += 4
assert t == 0x3ec                              # RELOC32
n = struct.unpack('>I', d[o:o+4])[0]; o += 4
assert n == 18
hn = struct.unpack('>I', d[o:o+4])[0]; o += 4
assert hn == 0
offs = [struct.unpack('>I', d[o+4*j:o+4+4*j])[0] for j in range(n)]
o += 4 * n
assert offs == [4*j for j in range(18)], offs  # already ascending
assert struct.unpack('>I', d[o:o+4])[0] == 0; o += 4
assert struct.unpack('>I', d[o:o+4])[0] == 0x3f2; o += 4   # END
assert o == len(d)
open(sys.argv[1], 'wb').write(d)
