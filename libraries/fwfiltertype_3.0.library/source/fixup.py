#!/usr/bin/env python3
"""Rewrite the RELOC32 tail to the original's layout:
   {3ec, 17, hunk=0, 17 offsets DESCENDING, 0, 3f2}.
   GNU ld emits ascending order; original stored them descending."""
import struct, sys

ORIG_RELOCS = [0x114, 0x9e, 0x8a, 0xc2, 0xb0, 0xa2, 0x9a, 0x96, 0x92,
               0x8e, 0x86, 0x82, 0x1a, 0x16, 0x12, 0xa, 0x6]

p = sys.argv[1]
d = bytearray(open(p, 'rb').read())
nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
o = 0x14 + 4*nh
tag, sz = struct.unpack('>II', d[o:o+8]); o += 8
assert tag == 0x3e9
o += (sz & 0x3fffffff) * 4
assert struct.unpack('>I', d[o:o+4])[0] == 0x3ec
o += 4
n = struct.unpack('>I', d[o:o+4])[0]
assert n == len(ORIG_RELOCS)
# overwrite the offsets in-place (same count, just ordering)
o += 4 + 4  # count + hunk num
for i, off in enumerate(ORIG_RELOCS):
    struct.pack_into('>I', d, o + 4*i, off)
open(p, 'wb').write(d)
