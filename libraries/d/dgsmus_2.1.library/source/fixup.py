#!/usr/bin/env python3
"""Splice the original hunk tail records into the linked dgsmus.library.

The verbatim .s uses literal operands only so gas emits no reloc records;
the original hunk-0 RELOC32 groups (31 hunk0 + 39 hunk1 + 1 hunk2 slots)
and the MEMF_CHIP flag bits on hunk 2 (hunk-table size entry + hunk type
word) are copied from the shipped binary after verifying each hunk body
matches byte-for-byte.
"""
import struct, sys

ORIG = "../binary/dgsmus_2.1.library"

def hunks(d):
    n = struct.unpack(">I", d[8:12])[0]
    o = 0x14 + n * 4
    out = []
    for _ in range(n):
        tag, sz = struct.unpack(">II", d[o:o+8]); sz &= 0x3fffffff
        body = o + 8
        end = body if (tag & 0x3fffffff) == 0x3eb else body + sz * 4
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
oh, _ = hunks(orig); mh, hdr = hunks(mine)
assert len(oh) == len(mh), "hunk count mismatch %d vs %d" % (len(oh), len(mh))
out = bytearray(orig[:hdr])
for (ot, osz, ob, oe, otail), (mt, msz, mb, me, _) in zip(oh, mh):
    assert orig[ob:oe] == mine[mb:me], "hunk body mismatch"
    out += struct.pack(">II", ot, osz) + orig[ob:oe] + otail
open(sys.argv[1], "wb").write(out)
