#!/usr/bin/env python3
# Post-link fixup: GNU ld emits the RELOC32 offset list in ascending order;
# the original linker emitted it in its own (partially descending) order.
# Rewrite the offset list to the original sequence.
import struct, sys

ORDER = [12, 16, 24, 28, 32, 252, 256, 260, 264, 318, 336, 348, 352, 356,
         304, 300, 296, 292, 288, 284, 280, 276, 272, 268,
         518, 570, 632, 746, 1844, 1852, 1860, 2040, 2024, 1996, 1972, 484]

d = bytearray(open(sys.argv[1], 'rb').read())
nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
o = 0x14 + 4 * nh
hsz = (struct.unpack('>I', d[o+4:o+8])[0] & 0x3fffffff) * 4
p = o + 8 + hsz
assert struct.unpack('>I', d[p:p+4])[0] == 0x3ec, 'expected RELOC32'
n = struct.unpack('>I', d[p+4:p+8])[0]
assert n == len(ORDER), (n, len(ORDER))
cur = sorted(struct.unpack('>I', d[p+12+4*i:p+16+4*i])[0] for i in range(n))
assert cur == sorted(ORDER), (cur, sorted(ORDER))
for i, off in enumerate(ORDER):
    struct.pack_into('>I', d, p+12+4*i, off)
open(sys.argv[1], 'wb').write(d)
