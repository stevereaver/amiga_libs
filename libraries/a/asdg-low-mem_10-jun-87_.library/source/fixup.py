#!/usr/bin/env python3
"""Rebuild the asdg-low-mem hunk envelope.

The linker emits a plain one-hunk file (header + CODE + relocs + END).
The original declares THREE hunks in the header table -- CODE first,
then two size-0 hunks -- and appends an empty DATA hunk and an empty
BSS hunk after the CODE hunk's END.  This script rewrites the header
and appends the two empty trailer hunks.
"""
import struct, sys

src, dst = sys.argv[1], sys.argv[2]
d = open(src, 'rb').read()

assert struct.unpack('>I', d[0:4])[0] == 0x3F3, 'not a hunk file'
assert struct.unpack('>I', d[4:8])[0] == 0, 'namelist'
nh, first, last = struct.unpack('>III', d[8:20])
assert (nh, first, last) == (1, 0, 0), (nh, first, last)
codesize = struct.unpack('>I', d[20:24])[0]

# original header: 3 hunks, sizes {code, 0, 0}
hdr = struct.pack('>IIIII', 0x3F3, 0, 3, 0, 2)
hdr += struct.pack('>III', codesize, 0, 0)

# body = everything after the 1-hunk header, then the two empty
# trailer hunks (DATA size 0 + END, BSS size 0 + END)
body = d[24:]
body += struct.pack('>III', 0x3EA, 0, 0x3F2)   # empty DATA hunk
body += struct.pack('>III', 0x3EB, 0, 0x3F2)   # empty BSS hunk

open(dst, 'wb').write(hdr + body)
