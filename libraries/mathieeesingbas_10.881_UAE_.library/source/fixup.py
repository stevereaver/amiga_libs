#!/usr/bin/env python3
# Post-link fixup for mathieeesingbas.library 10.881 (UAE).
#
# GNU ld emits the 8 AUTOINIT pointer relocs as a standard HUNK_RELOC32
# (0x3ec) record with 32-bit offsets in ascending order.  The original
# was linked with the compact hunk type 0x3f7 record used by the old
# Commodore toolchain: {count:word, hunk:word} followed by 16-bit
# offsets in *descending* order, terminated by a zero longword.
# This script verifies the ld output and rewrites the tail.
import struct, sys

# original tail after the code hunk: 0x3f7 record, 8 word offsets
ORIG_OFFS = [0x28, 0x24, 0x20, 0x18, 0x14, 0x10, 0x08, 0x04]

d = bytearray(open(sys.argv[1], 'rb').read())
assert struct.unpack('>I', d[0:4])[0] == 0x3f3
nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
assert nh == 1, 'expected single-hunk ld output'

o = 0x14 + 4 * nh
tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
assert tag == 0x3e9
sz = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff; o += 4
assert sz == 0x72, hex(sz)
body = d[o:o + sz*4]; o += sz*4

t = struct.unpack('>I', d[o:o+4])[0]; o += 4
assert t == 0x3ec, hex(t)
got = []
while True:
    n = struct.unpack('>I', d[o:o+4])[0]; o += 4
    if n == 0:
        break
    hn = struct.unpack('>I', d[o:o+4])[0]; o += 4
    for j in range(n):
        got.append((hn, struct.unpack('>I', d[o+4*j:o+4+4*j])[0]))
    o += 4 * n
assert sorted(got) == sorted((0, x) for x in ORIG_OFFS), got
assert struct.unpack('>I', d[o:o+4])[0] == 0x3f2      # HUNK_END
assert o + 4 == len(d)                                # nothing after END

out = bytearray()
out += d[:0x20] + body                                # header + code hunk
out += struct.pack('>I', 0x3f7)                       # DREL reloc record
out += struct.pack('>HH', len(ORIG_OFFS), 0)          # count, hunk 0
for x in ORIG_OFFS:
    out += struct.pack('>H', x)                       # 16-bit offsets, desc
out += struct.pack('>I', 0)                           # terminator
out += struct.pack('>I', 0x3f2)                       # HUNK_END
open(sys.argv[1], 'wb').write(out)
