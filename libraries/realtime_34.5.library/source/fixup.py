#!/usr/bin/env python3
# realtime 34.5: single CODE hunk (declared==physical 4456B @0x20),
# RELOC32 tail (29 slots ->h0) + END. Verify body, splice orig tail.
import struct, sys
ORIG = "../binary/realtime_34.5.library"
orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
body = orig[0x20:0x1188]
n = struct.unpack(">I", mine[8:12])[0]
o = 0x14 + n * 4
tag, sz = struct.unpack(">II", mine[o:o+8]); sz &= 0x3fffffff
assert tag == 0x3e9 and mine[o+8:o+8+len(body)] == body, "body mismatch"
out = orig[:0x20] + body + orig[0x1188:]
open(sys.argv[1], "wb").write(out)
