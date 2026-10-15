#!/usr/bin/env python3
# Post-link fixup: GNU ld emits the RELOC32 offset list in ascending order;
# the original linker emitted it in its own (partially descending) order.
# Rewrite the offset list to the original sequence.
import struct, sys

ORDER = [642, 650, 690, 810, 816, 822, 834, 888, 896, 906, 1346, 1352,
         1426, 1568, 1584, 1590, 1612, 1618, 1628, 1818, 1884, 1898,
         1914, 1962, 1968, 558, 534, 6, 10, 18, 22, 26, 114, 118, 122,
         126, 130, 134, 138, 142, 146, 150, 154, 158, 162, 180, 206]

d = bytearray(open(sys.argv[1], 'rb').read())
nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
o = 0x14 + 4 * nh
hsz = (struct.unpack('>I', d[o+4:o+8])[0] & 0x3fffffff) * 4
p = o + 8 + hsz
assert struct.unpack('>I', d[p:p+4])[0] == 0x3ec, 'expected RELOC32'
n = struct.unpack('>I', d[p+4:p+8])[0]
assert n == len(ORDER), (n, len(ORDER))
cur = sorted(struct.unpack('>I', d[p+12+4*i:p+16+4*i])[0] for i in range(n))
assert cur == sorted(ORDER)
for i, off in enumerate(ORDER):
    struct.pack_into('>I', d, p+12+4*i, off)
open(sys.argv[1], 'wb').write(d)
