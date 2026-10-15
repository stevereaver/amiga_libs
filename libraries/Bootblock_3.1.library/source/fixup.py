#!/usr/bin/env python3
"""Rebuild Bootblock.library 3.1 from linked output + original tails.

The verbatim .s emits one .text blob = hunk0+hunk3 code, and one
.data blob = hunk1 strings/functab + hunk2 zero-DATA.  fixup
splits both blobs back into the original 4-hunk layout, restores
the original header/tags, and splices all relocation tails
verbatim (cross-hunk relocs h0<->h1/h2/h3, h1->h0/h3, h3->h2).
"""
import struct, sys

ORIG = "../binary/Bootblock_3.1.library"

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
assert len(oh) == 4 and len(mh) == 2, (len(oh), len(mh))
mtxt = mine[mh[0][1]:mh[0][2]]
mdat = mine[mh[1][1]:mh[1][2]]
# orig: h0 CODE (first part of .text), h1 CODE (first part of .data),
#       h2 DATA (second part of .data), h3 CODE (second part of .text)
ob0, ob1, ob2, ob3 = [orig[h[1]:h[2]] for h in oh]
s0 = len(ob0); s1 = len(ob1); s2 = len(ob2)
assert mtxt[:s0] == ob0, "hunk0 body mismatch"
assert mtxt[s0:] == ob3, "hunk3 body mismatch"
assert mdat[:s1] == ob1, "hunk1 body mismatch"
assert mdat[s1:] == ob2, "hunk2 body mismatch"
out = bytearray(orig[:ohdr])
for (ot, ob, oe, otail) in oh:
    out += struct.pack(">II", ot, (oe - ob) // 4) + orig[ob:oe] + otail
open(sys.argv[1], "wb").write(out)
print("fixup ok")
