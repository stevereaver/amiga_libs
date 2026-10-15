#!/usr/bin/env python3
# Garshnelib 39.1: h0 CODE declared 0x435 longs + 4B body overrun
# to 0x10f8 (ends '4e75 0000'), RELOC32 22 slots ->h0, END.
# h1 DATA 0x34 longs @0x1180..0x1250, RELOC32 2 slots ->h0, END.
import struct, sys
ORIG = "../binary/Garshnelib_39.1.library"
orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
b0 = orig[0x24:0x10f8]; b1 = orig[0x1180:0x1250]
n = struct.unpack(">I", mine[8:12])[0]
o = 0x14 + n * 4
bodies = []
for i in range(n):
    t, s = struct.unpack(">II", mine[o:o+8]); s &= 0x3fffffff
    bodies.append(mine[o+8:o+8+s*4]); o += 8 + s * 4
    while True:
        t2 = struct.unpack(">I", mine[o:o+4])[0]; o += 4
        if t2 == 0x3f2:
            break
        if t2 == 0x3ec:
            while True:
                c = struct.unpack(">I", mine[o:o+4])[0]; o += 4
                if c == 0: break
                o += 4 + c * 4
        elif t2 == 0x3f0:
            while True:
                c = struct.unpack(">I", mine[o:o+4])[0]; o += 4
                if c == 0: break
                o += c * 4 + 4
        elif t2 in (0x3e8, 0x3f1):
            c = struct.unpack(">I", mine[o:o+4])[0]; o += 4 + c * 4
        else:
            sys.exit("unknown tail tag %x @%x" % (t2, o-4))
assert bodies[0] == b0 and bodies[1] == b1, "body mismatch"
out = orig[:0x24] + b0 + orig[0x10f8:0x1180] + b1 + orig[0x1250:]
open(sys.argv[1], "wb").write(out)
