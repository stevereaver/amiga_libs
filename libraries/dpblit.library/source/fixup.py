#!/usr/bin/env python3
"""Restore the shipped 4-hunk layout of dpblit.library.

The original is CODE 0x27e longs + DATA 8 longs (InitTable) +
DATA|CHIP 0x80 longs (zeroed blit buffer) + CODE 0xf longs
(functab + name/idstring).  The verbatim .s puts all four bodies
into a single .text section (literal operands only, so gas emits
no reloc records).  This script asserts the concatenated
generated hunk bodies match the original byte-for-byte, then
rewrites the file as: original header (with the CHIP flag on
hunk2's size word) + per-hunk tag/size + body + original
RELOC32/END tail.
"""
import struct, sys

ORIG = "../binary/dpblit.library"

def hunks(d):
    n = struct.unpack(">I", d[8:12])[0]
    o = 0x14 + n * 4
    out = []
    for _ in range(n):
        tagsz = d[o:o + 8]
        sz = struct.unpack(">I", tagsz[4:8])[0] & 0x3fffffff
        body = o + 8; end = body + sz * 4
        j = end
        while struct.unpack(">I", d[j:j+4])[0] != 0x3f2:
            t = struct.unpack(">I", d[j:j+4])[0]; j += 4
            if t == 0x3ec:
                while True:
                    c = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if c == 0: break
                    j += 4 + c * 4
            elif t == 0x3f0:
                while True:
                    nl = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if nl == 0: break
                    j += nl * 4 + 4
            elif t in (0x3e8, 0x3f1):
                j += 4 + struct.unpack(">I", d[j:j+4])[0] * 4
            else:
                sys.exit("unknown tail tag %x" % t)
        j += 4
        out.append((tagsz, body, end, d[end:j]))
        o = j
    return out, 0x14 + n * 4

orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
oh, ohdr = hunks(orig); mh, _ = hunks(mine)
obody = b"".join(orig[ob:oe] for _, ob, oe, _ in oh)
mbody = b"".join(mine[mb:me] for _, mb, me, _ in mh)
assert obody == mbody, "hunk body mismatch"
out = bytearray(orig[:ohdr])
for ots, ob, oe, otail in oh:
    out += ots + orig[ob:oe] + otail
open(sys.argv[1], "wb").write(out)
