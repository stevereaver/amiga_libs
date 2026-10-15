#!/usr/bin/env python3
# calculus 37.3: h0 CODE 0x457 longs @0x24..0x1180, RELOC32(20)+END;
# h1 DATA 0x13 longs @0x120c..0x1258, RELOC32(6->h0)+END.
import struct, sys
ORIG = "../binary/calculus_37.3.library"
orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
b0 = orig[0x24:0x1180]; b1 = orig[0x120c:0x1258]
n = struct.unpack(">I", mine[8:12])[0]
o = 0x14 + n * 4
bodies = []
for i in range(n):
    t, s = struct.unpack(">II", mine[o:o+8]); s &= 0x3fffffff
    bodies.append(mine[o+8:o+8+s*4]); o += 8 + s * 4
    while True:
        t2 = struct.unpack(">I", mine[o:o+4])[0]; o += 4
        if t2 == 0x3f2: break
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
            sys.exit("unknown tail tag %x" % t2)
assert bodies[0] == b0 and bodies[1] == b1, "body mismatch"
out = orig[:0x24] + b0 + orig[0x1180:0x120c] + b1 + orig[0x1258:]
open(sys.argv[1], "wb").write(out)
