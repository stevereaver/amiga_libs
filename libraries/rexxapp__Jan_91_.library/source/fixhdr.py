#!/usr/bin/env python3
# Post-link fixup: the original rexxapp.library hunk header declares
# TWO hunks (sizes [0x162, 0]) and the file ends with an empty second
# CODE hunk (03e9/0/03f2) after hunk0's END.  GNU ld emits a single
# hunk, so rewrite the header and append the trailing empty hunk.
import struct, sys

src, dst = sys.argv[1], sys.argv[2]
d = open(src, 'rb').read()
assert struct.unpack('>I', d[0:4])[0] == 0x3f3, 'not a hunk file'
# orig header: 03f3 | resname(0) | num=2 | first=0 | last=1 |
#              hunk0size | hunk1size=0
# new (single hunk): 03f3 | 0 | num=1 | 0 | 0 | hunk0size
num = struct.unpack('>I', d[8:12])[0]
assert num == 1
h0size = struct.unpack('>I', d[0x14:0x18])[0]
rest = d[0x18:]            # hunk0 header (03e9+size) + body + relocs + END
out = struct.pack('>7I', 0x3f3, 0, 2, 0, 1, h0size, 0) + rest
out += struct.pack('>3I', 0x3e9, 0, 0x3f2)   # empty CODE hunk + END
open(dst, 'wb').write(out)
