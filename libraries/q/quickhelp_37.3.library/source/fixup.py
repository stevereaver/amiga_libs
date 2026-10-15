#!/usr/bin/env python3
"""Rebuild quickhelp.library from the linked output + original tails.

The verbatim .s emits hunk0 (.text) plus a single .data blob holding
hunks 1+2+3 (InitTable, string table, functab+names) with literal
reloc-slot values.  This splits the .data blob at 16/456/76 and
writes the original's header, per-hunk tags, and relocation tails.
"""
import struct, sys

ORIG = "../binary/quickhelp_37.3.library"

def hunks(d):
    n = struct.unpack(">I", d[8:12])[0]
    o = 0x14 + n * 4
    out = []
    while o < len(d):
        t = struct.unpack(">I", d[o:o+4])[0]; o += 4
        if t == 0x3f2:
            continue
        if t in (0x3e9, 0x3ea, 0x3eb):
            sz = struct.unpack(">I", d[o:o+4])[0] & 0x3fffffff; o += 4
            body = o; o += sz * 4
            j = o
            while struct.unpack(">I", d[j:j+4])[0] != 0x3f2:
                tt = struct.unpack(">I", d[j:j+4])[0]; j += 4
                if tt == 0x3ec:
                    while True:
                        c = struct.unpack(">I", d[j:j+4])[0]; j += 4
                        if c == 0: break
                        j += 4 + c * 4
                elif tt == 0x3f0:
                    while True:
                        nl = struct.unpack(">I", d[j:j+4])[0]; j += 4
                        if nl == 0: break
                        j += nl * 4 + 4
                elif tt in (0x3e8, 0x3f1):
                    j += 4 + struct.unpack(">I", d[j:j+4])[0] * 4
                else:
                    sys.exit("unknown tail tag %x" % tt)
            j += 4
            out.append((t, body, body + sz * 4, d[body + sz * 4:j]))
            o = j
        else:
            break
    return out, 0x14 + n * 4

orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
oh, ohdr = hunks(orig); mh, hdr = hunks(mine)
assert len(oh) == 4 and len(mh) == 2, (len(oh), len(mh))
assert orig[oh[0][1]:oh[0][2]] == mine[mh[0][1]:mh[0][2]], "hunk0 body mismatch"
dblob = mine[mh[1][1]:mh[1][2]]
split = [oh[k][2] - oh[k][1] for k in (1, 2, 3)]
assert sum(split) == len(dblob), (split, len(dblob))
assert dblob[:split[0]] == orig[oh[1][1]:oh[1][2]]
assert dblob[split[0]:split[0]+split[1]] == orig[oh[2][1]:oh[2][2]]
assert dblob[split[0]+split[1]:] == orig[oh[3][1]:oh[3][2]]
# bodies verified: emit original header + original hunks/tails verbatim
out = bytearray(orig[:ohdr])
for (ot, ob, oe, otail) in oh:
    out += struct.pack(">II", ot, (oe - ob) // 4) + orig[ob:oe] + otail
open(sys.argv[1], "wb").write(out)
print("fixup ok")
