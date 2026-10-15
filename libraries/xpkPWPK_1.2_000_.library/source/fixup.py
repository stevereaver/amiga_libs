#!/usr/bin/env python3
"""Splice the original RELOC32 tail into the linked xpkPWPK.library.

The verbatim .s uses literal/symbolic operands resolved by GNU ld; any
relocs it emits are discarded -- after verifying every hunk body is
byte-identical we copy the shipped binary's tail (RELOC32 groups +
HUNK_END) wholesale.
"""
import struct, sys

ORIG = "../binary/xpkPWPK_1.2(000).library"

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
            if t == 0x3ec:
                while True:
                    c = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if c == 0: break
                    j += 4 + c * 4
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
assert len(oh) == len(mh), "hunk count mismatch"
out = bytearray(orig[:hdr])
for (ot, ob, oe, otail), (mt, mb, me, _) in zip(oh, mh):
    assert ot == mt, "hunk tag mismatch %x vs %x" % (ot, mt)
    assert orig[ob:oe] == mine[mb:me], "hunk body mismatch"
    out += struct.pack(">II", ot, (oe - ob) // 4) + orig[ob:oe] + otail
open(sys.argv[1], "wb").write(out)
