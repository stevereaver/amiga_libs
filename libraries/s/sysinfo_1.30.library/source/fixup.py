#!/usr/bin/env python3
"""Rebuild SysInfo.library 2.00 from linked output + original tails.

The verbatim .s emits hunk0 (.text) plus a single .data blob holding
the original's hunk1 (28B InitTable DATA) and hunk2 (108B functab +
strings CODE).  fixup splits the blob, restores the original 3-hunk
header/tags, and splices the original relocation tails.
"""
import struct, sys

ORIG = "../binary/sysinfo_1.30.library"

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
            body = o; o += (0 if t == 0x3eb else sz * 4)
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
            out.append((t, body, o, d[o:j]))
            o = j
        else:
            break
    return out, 0x14 + n * 4

orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
oh, ohdr = hunks(orig); mh, hdr = hunks(mine)
assert len(oh) == 3 and len(mh) == 2, (len(oh), len(mh))
assert orig[oh[0][1]:oh[0][2]] == mine[mh[0][1]:mh[0][2]], "hunk0 body mismatch"
dblob = mine[mh[1][1]:mh[1][2]]
s1 = oh[1][2] - oh[1][1]          # 28B InitTable
s2 = oh[2][2] - oh[2][1]          # 108B functab+strings
assert s1 + s2 == len(dblob), (s1, s2, len(dblob))
assert dblob[:s1] == orig[oh[1][1]:oh[1][2]], "hunk1 body mismatch"
assert dblob[s1:] == orig[oh[2][1]:oh[2][2]], "hunk2 body mismatch"
out = bytearray(orig[:ohdr])
for (ot, ob, oe, otail) in oh:
    out += struct.pack(">II", ot, (oe - ob) // 4) + orig[ob:oe] + otail
open(sys.argv[1], "wb").write(out)
print("fixup ok")
