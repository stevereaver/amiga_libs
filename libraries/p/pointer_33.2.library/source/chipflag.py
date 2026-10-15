#!/usr/bin/env python3
# chipflag.py -- set the MEMF_CHIP flag (bit 30) on the second hunk of
# an Amiga hunk-format file, both in the hunk-table size entry and in
# the hunk type word.  The toolchain emits .datachip as a plain data
# hunk; the original pointer.library marks its bitmap hunk CHIP.

import struct
import sys

MEMF_CHIP = 0x40000000
path = sys.argv[1]
d = bytearray(open(path, "rb").read())

assert struct.unpack(">L", d[0:4])[0] == 0x000003F3, "no hunk header"
nhunks, first, last = struct.unpack(">LLL", d[8:20])
idx = first + 1                     # hunk 1 = the bitmap hunk

# hunk-table size entry
sz_off = 20 + 4 * idx
size = struct.unpack(">L", d[sz_off:sz_off + 4])[0]
struct.pack_into(">L", d, sz_off, size | MEMF_CHIP)

# walk hunks to find the type word of hunk `idx`
p = 20 + 4 * nhunks
cur = first
while p < len(d):
    htype = struct.unpack(">L", d[p:p + 4])[0]
    base = htype & 0x3FFFFFFF
    if base in (0x3E9, 0x3EA):
        if cur == idx:
            struct.pack_into(">L", d, p, htype | MEMF_CHIP)
            break
        sz = struct.unpack(">L", d[p + 4:p + 8])[0] & 0x3FFFFFFF
        p += 8 + sz * 4
        cur += 1
    elif base == 0x3EB:
        cur += 1
        p += 8
    elif base == 0x3F0:
        p += 4
        while True:
            nl = struct.unpack(">L", d[p:p + 4])[0]
            p += 4
            if nl == 0:
                break
            p += nl * 4 + 4
    elif base == 0x3EC:
        p += 4
        while True:
            c = struct.unpack(">L", d[p:p + 4])[0]
            p += 4
            if c == 0:
                break
            p += 4 + c * 4
    elif base == 0x3F2:
        p += 4
    else:
        sys.exit("unexpected hunk word %08x at %x" % (htype, p))
else:
    sys.exit("chip hunk not found")

open(path, "wb").write(d)
