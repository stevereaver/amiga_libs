#!/usr/bin/env python3
"""Restore the shipped hunk layout of asyncio.library 39.2.

The original is 2 hunks: CODE 0x307 longs + a 5-long BSS hunk
(hunk tag 0x3eb carries no body in the file).  The verbatim .s
uses literal operands only, so gas emits no reloc records; the
original RELOC32 tail (h0->h0 functab/operands + h0->h1 BSS
pointer operands) is spliced back verbatim after asserting the
generated code body matches.  The linked DATA hunk (all zeros)
is re-emitted as the original BSS tail-only hunk.
"""
import struct, sys

ORIG = "../binary/asyncio_39.2.library"

def hunks(d):
    n = struct.unpack(">I", d[8:12])[0]
    o = 0x14 + n * 4
    out = []
    for _ in range(n):
        tag, sz = struct.unpack(">II", d[o:o+8]); sz &= 0x3fffffff
        body = o + 8
        if tag == 0x3eb:
            end = body            # BSS: no body in file
        else:
            end = body + sz * 4
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
        out.append((tag, sz, body, end, d[end:j]))
        o = j
    return out, 0x14 + n * 4

orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
oh, _ = hunks(orig); mh, hdr = hunks(mine)
assert len(oh) == len(mh)
out = bytearray(orig[:hdr])
for (ot, osz, ob, oe, otail), (mt, msz, mb, me, _) in zip(oh, mh):
    if ot == 0x3eb:
        # original BSS hunk: tag+size+tail only; linked DATA body
        # must be all zeros and the same size
        assert mine[mb:me] == b"\0" * msz * 4 and msz == osz
    else:
        assert orig[ob:oe] == mine[mb:me], "hunk body mismatch"
    out += struct.pack(">II", ot, osz) + orig[ob:oe] + otail
open(sys.argv[1], "wb").write(out)
