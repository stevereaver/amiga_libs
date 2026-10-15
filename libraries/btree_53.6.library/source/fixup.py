#!/usr/bin/env python3
# splice the original hunk tails (reloc32/symbol/name) into our link.
import struct, sys
ORIG = sys.argv[2]
def hunks(d):
    n = struct.unpack(">I", d[8:12])[0]
    o = 0x14 + 4*n
    out = []
    for _ in range(n):
        tag, sz = struct.unpack(">II", d[o:o+8]); sz &= 0x3fffffff
        b = o + 8; e = b + sz*4
        j = e
        while struct.unpack(">I", d[j:j+4])[0] != 0x3f2:
            t = struct.unpack(">I", d[j:j+4])[0]; j += 4
            if t == 0x3ec:
                while True:
                    c = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if c == 0: break
                    j += 4 + c*4
            elif t == 0x3f0:
                while True:
                    nl = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if nl == 0: break
                    j += nl*4 + 4
            elif t in (0x3e8,0x3f1,0x3f4,0x3f6):
                j += 4 + struct.unpack(">I", d[j:j+4])[0]*4
            else:
                sys.exit("tail tag %x" % t)
        j += 4
        out.append((tag, b, e, d[e:j]))
        o = j
    return out
orig = open(ORIG,"rb").read(); mine = open(sys.argv[1],"rb").read()
oh, mh = hunks(orig), hunks(mine)
out = bytearray(orig[:0x14 + 4*struct.unpack(">I",orig[8:12])[0]])
for (ot,ob,oe,otail),(mt,mb,me,_) in zip(oh, mh):
    assert orig[ob:oe] == mine[mb:me], "hunk body mismatch"
    out += struct.pack(">II", ot, (oe-ob)//4) + orig[ob:oe] + otail
open(sys.argv[1],"wb").write(out)
