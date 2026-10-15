#!/usr/bin/env python3
"""Rebuild the 13-hunk diskfont.library image.

The verbatim .s assembles into one big CODE hunk (.text) plus one
DATA hunk (.data); all operands are literals so the linker emits no
reloc records.  This script verifies that .text equals the
concatenation of the original CODE-hunk bodies (in hunk order) and
.data likewise for the DATA hunks, then re-emits the original
header and every hunk with its original tag/size/body/reloc tail.

Hunks 8 (DATA) and 9 (CODE) are empty in the shipped binary.
"""
import struct, sys

ORIG = "../binary/diskfont_1.3(WB1.0).library"

def hunks(d):
    n = struct.unpack(">I", d[8:12])[0]
    o = 0x14 + n * 4
    out = []
    for _ in range(n):
        tag, sz = struct.unpack(">II", d[o:o+8]); sz &= 0x3fffffff
        body = o + 8
        end = body if tag == 0x3eb else body + sz * 4   # BSS has no body
        j = end
        while True:
            j += (-j) & 3            # tail tags are longword aligned
            t = struct.unpack(">I", d[j:j+4])[0]; j += 4
            if t == 0x3f2:
                break
            if t == 0x3ec:           # RELOC32: long count/hunkno/offsets
                while True:
                    c = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if c == 0: break
                    j += 4 + c * 4
            elif t == 0x3f7:         # DREL16: word count/hunkno/offsets
                while True:
                    c = struct.unpack(">H", d[j:j+2])[0]; j += 2
                    if c == 0: break
                    j += 2 + c * 2
            elif t == 0x3f0:
                while True:
                    nl = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if nl == 0: break
                    j += nl * 4 + 4
            elif t in (0x3e8, 0x3f1):
                j += 4 + struct.unpack(">I", d[j:j+4])[0] * 4
            else:
                sys.exit("unknown tail tag %x at %x" % (t, j - 4))
        out.append((tag, sz, body, end, d[end:j]))
        o = j
    return out, 0x14 + n * 4

orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
oh, ohdr = hunks(orig)
mh, _ = hunks(mine)

# collect the rebuilt bodies by hunk type
mcode = b"".join(mine[b:e] for t, s, b, e, _ in mh if t == 0x3e9)
mdata = b"".join(mine[b:e] for t, s, b, e, _ in mh if t == 0x3ea)
ocode = b"".join(orig[b:e] for t, s, b, e, _ in oh if t == 0x3e9)
odata = b"".join(orig[b:e] for t, s, b, e, _ in oh if t == 0x3ea)
assert mcode == ocode, "code hunk bodies differ"
assert mdata == odata, "data hunk bodies differ"

out = bytearray(orig[:ohdr])
for tag, sz, b, e, tail in oh:
    out += struct.pack(">II", tag, sz)
    if tag != 0x3eb:
        out += orig[b:e]
    out += tail
open(sys.argv[1], "wb").write(out)
print("fixup ok")
