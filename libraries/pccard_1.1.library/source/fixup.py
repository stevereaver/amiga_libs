#!/usr/bin/env python3
"""Splice the original RELOC32 tail into the linked pccard.library.

Single flat CODE hunk (0x50d longs).  The verbatim .s uses literal
operands only so gas emits no reloc records; the 49-entry RELOC32
group (all -> hunk 0) is copied from the shipped binary after
verifying the hunk body matches byte for byte.
"""
import struct, sys

ORIG = "../binary/pccard_1.1.library"

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
            body = o
            o += 0 if tag == 0x3eb else sz * 4
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
                        j += 2 + c * 2
                    if j & 2: j += 2
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
            out.append((tag, body, body + (0 if tag == 0x3eb else sz * 4),
                        d[body + (0 if tag == 0x3eb else sz * 4):j]))
            o = j
        else:
            break
    return out, 0x14 + n * 4

orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
oh, ohdr = hunks(orig)
mh, _ = hunks(mine)
assert len(oh) == 1 and len(mh) >= 1, (len(oh), len(mh))
assert orig[oh[0][1]:oh[0][2]] == mine[mh[0][1]:mh[0][2]], "hunk0 body mismatch"
out = bytearray(orig[:ohdr])
out += struct.pack(">II", oh[0][0], (oh[0][2] - oh[0][1]) // 4) \
       + orig[oh[0][1]:oh[0][2]] + oh[0][3]
open(sys.argv[1], "wb").write(out)
print("fixup ok")
