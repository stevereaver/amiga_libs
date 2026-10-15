#!/usr/bin/env python3
"""Append the original RELOC32 tail to the linked xpkTDCS binary.

The verbatim .s uses literal operands only, so gas/ld emit no relocation
records.  The original's reloc groups (descending order, 18 sites) are
copied verbatim after verifying the hunk body matches.
"""
import struct, sys

ORIG = "../binary/xpkTDCS_1.2.library"

def hunks(d):
    n = struct.unpack(">I", d[8:12])[0]
    o = 0x14 + n * 4
    out = []
    for _ in range(n):
        tag, sz = struct.unpack(">II", d[o:o+8]); sz &= 0x3fffffff
        body = o + 8; end = body + sz * 4
        j = end
        while struct.unpack(">I", d[j:j+4])[0] != 0x3f2:
            t = struct.unpack(">I", d[j:j+4])[0]; j += 4
            if t in (0x3ec, 0x3f7, 0x3ef):
                while True:
                    c = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if c == 0: break
                    j += (4 + c * 4) if t == 0x3ec else (4 + c * 4)
            elif t in (0x3e8, 0x3f0, 0x3f1):
                j += 4 + struct.unpack(">I", d[j:j+4])[0] * 4
            else:
                sys.exit("unknown tail tag %x" % t)
        j += 4
        out.append((tag, body, end, d[end:j]))
        o = j
    return out, 0x14 + n * 4

orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
oh, _ = hunks(orig); mh, hdr = hunks(mine)
assert len(oh) == len(mh)
out = bytearray(mine[:hdr])
for (ot, ob, oe, otail), (mt, mb, me, _) in zip(oh, mh):
    assert ot == mt and oe - ob == me - mb and orig[ob:oe] == mine[mb:me]
    out += struct.pack(">II", mt, (me - mb) // 4) + mine[mb:me] + otail
open(sys.argv[1], "wb").write(out)
