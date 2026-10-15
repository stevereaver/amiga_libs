#!/usr/bin/env python3
# mdb 34.46: h0 declared 0x45f longs (4476B) + 4B body overrun to
# 0x11a8, RELOC32 groups, END; then two empty hunks (CODE+DATA).
import struct, sys
ORIG = "../binary/mathieeedoubbas_34.46.library"
orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
body = orig[0x28:0x11a8]
n = struct.unpack(">I", mine[8:12])[0]
o = 0x14 + n * 4
tag, sz = struct.unpack(">II", mine[o:o+8]); sz &= 0x3fffffff
assert tag == 0x3e9 and mine[o+8:o+8+len(body)] == body, "body mismatch"
out = orig[:0x28] + body + orig[0x11a8:]
open(sys.argv[1], "wb").write(out)
