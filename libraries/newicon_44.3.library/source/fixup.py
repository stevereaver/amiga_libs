#!/usr/bin/env python3
"""Rebuild newicon_44.3.library: verify bodies, splice orig structure.

Linked output is h0(.text CODE) + h1(.data = orig DATA 236B +
12B BSS placeholder).  This copies the original's 3-hunk header,
per-hunk tags (incl. the body-less BSS hunk2) and DREL16 tails.
"""
import struct, sys

ORIG = "../binary/newicon_44.3.library"

def hunks(d):
    n = struct.unpack(">I", d[8:12])[0]
    o = 0x14 + n * 4
    out = []
    while o < len(d):
        t = struct.unpack(">I", d[o:o+4])[0]
        if t == 0x3f2:
            o += 4
            continue
        if t in (0x3e9, 0x3ea, 0x3eb):
            tag = t; o += 4
            sz = struct.unpack(">I", d[o:o+4])[0] & 0x3fffffff; o += 4
            body = o; o += 0 if tag == 0x3eb else sz * 4
            j = o
            while struct.unpack(">I", d[j:j+4])[0] != 0x3f2:
                tt = struct.unpack(">I", d[j:j+4])[0]
                if tt == 0x3ec:
                    j += 4
                    while True:
                        c = struct.unpack(">I", d[j:j+4])[0]; j += 4
                        if c == 0: break
                        j += 4 + c * 4
                elif tt == 0x3f7:
                    j += 4
                    while True:
                        c = struct.unpack(">H", d[j:j+2])[0]; j += 2
                        if c == 0: break
                        j += 2 + c * 2          # skip hunkno word + offsets
                    if j & 2: j += 2            # pad to long-align END
                elif tt == 0x3f0:
                    j += 4
                    while True:
                        nl = struct.unpack(">I", d[j:j+4])[0]; j += 4
                        if nl == 0: break
                        j += nl * 4 + 4
                elif tt in (0x3e8, 0x3f1):
                    j += 4 + struct.unpack(">I", d[j:j+4])[0] * 4
                else:
                    sys.exit("unknown tail tag %x @%x" % (tt, j))
            j += 4
            out.append((tag, body, body + sz * 4, d[body + sz * 4:j]))
            o = j
        else:
            break
    return out, 0x14 + n * 4

orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
oh, ohdr = hunks(orig)
mh, _ = hunks(mine)
assert len(oh) == 3 and len(mh) == 2, (len(oh), len(mh))
assert orig[oh[0][1]:oh[0][2]] == mine[mh[0][1]:mh[0][2]], "hunk0 mismatch"
dln = mh[1][2] - mh[1][1]
oln = oh[1][2] - oh[1][1]
assert dln == oln + 12, (dln, oln)
assert mine[mh[1][1]:mh[1][1]+oln] == orig[oh[1][1]:oh[1][2]], "hunk1 mismatch"
assert mine[mh[1][1]+oln:mh[1][2]] == b"\x00" * 12, "bss placeholder"

out = bytearray(orig[:ohdr])
# hunk0 + hunk1 verbatim with their original tails
for (ot, ob, oe, otail) in oh[:2]:
    out += struct.pack(">II", ot, (oe - ob) // 4) + orig[ob:oe] + otail
# hunk2: body-less BSS record + its END
out += struct.pack(">II", 0x3eb, 3) + struct.pack(">I", 0x3f2)
open(sys.argv[1], "wb").write(out)
print("fixup ok")
