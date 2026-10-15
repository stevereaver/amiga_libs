#!/usr/bin/env python3
"""Splice the original RELOC32 tails into the linked xpkNUKE.library.

The verbatim .s files use literal operands only so gas/ld emit no reloc
records; after verifying every hunk body is byte-identical we copy the
shipped binary's per-hunk tails (RELOC32 groups + HUNK_END) wholesale.

Original layout:
  hunk0 CODE 0xaf4: RELOC32 16 -> h0 (aa4..ac8 functab + 5a,42,16,12,a,6
                    romtag/init name/id refs) then 2 -> h1 (66,1a)
  hunk1 DATA 0x140: RELOC32 2 -> h0 (8 = functab, 10 = initfn)
"""
import struct, sys

ORIG = "../binary/xpkNUKE_1.1.library"

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
