#!/usr/bin/env python3
"""Splice RELOC32 tails into the linked 68020.library 43.2 binary.

gas/ld emit no RELOC32 records for the verbatim .s (all operands are
literals), so this script takes the reloc group bytes verbatim from the
original binary and grafts them after each hunk body.
"""
import struct, sys

ORIG = "../binary/68020_43.2(MMU).library"

def hunks(d):
    """Return [(tag, body_off, body_len, tail_bytes)] and header_len."""
    n = struct.unpack(">I", d[8:12])[0]
    o = 0x14 + n * 4
    out = []
    for _ in range(n):
        tag, sz = struct.unpack(">II", d[o:o+8]); sz &= 0x3fffffff
        body = o + 8; end = body + sz * 4
        j = end
        while struct.unpack(">I", d[j:j+4])[0] != 0x3f2:
            t = struct.unpack(">I", d[j:j+4])[0]; j += 4
            if t == 0x3ec:                       # RELOC32
                while True:
                    c = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if c == 0: break
                    j += 4 + c * 4
            elif t in (0x3eb, 0x3e8, 0x3f0, 0x3f1):
                j += 4 + struct.unpack(">I", d[j:j+4])[0] * 4
            else:
                sys.exit("unknown hunk tail tag %x" % t)
        j += 4                                    # HUNK_END
        out.append((tag, body, end, d[end:j]))
        o = j
    return out, 0x14 + n * 4

orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
oh, _ = hunks(orig)
mh, hdr_end = hunks(mine)
assert len(oh) == len(mh)

out = bytearray(mine[:hdr_end])
for (otag, obody, oend, otail), (mtag, mbody, mend, _) in zip(oh, mh):
    assert otag == mtag and (oend - obody) == (mend - mbody)
    assert orig[obody:oend] == mine[mbody:mend], "hunk body mismatch"
    out += struct.pack(">II", mtag, (mend - mbody) // 4)
    out += mine[mbody:mend]
    out += otail                              # reloc groups + HUNK_END, verbatim
open(sys.argv[1], "wb").write(out)
