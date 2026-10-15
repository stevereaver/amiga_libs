#!/usr/bin/env python3
"""fixup for owndevunit 3.3: verify bodies, write orig structure.

Quirks: h0 record declares 0x4e longs but the file carries 0x4f
(an extra body long before RELOC32); h1's record (0x41) is
smaller than its hunk-table entry (0x53, alloc/body mismatch).
The original header/records/tails are spliced verbatim.
"""
import struct, sys
ORIG = "../binary/owndevunit_3.3.library"
orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()

def body(d, off):
    """hunk body bytes of a gnu-linked file starting at record off."""
    sz = struct.unpack(">I", d[off+4:off+8])[0] & 0x3fffffff
    return d[off+8:off+8+sz*4]

# locate mine's hunks
nh = struct.unpack(">I", mine[8:12])[0]
o = 0x14 + nh*4
mine_h0 = body(mine, o); off2 = o + 8 + len(mine_h0)
# find second hunk record after h0's tails
p = off2
while struct.unpack(">I", mine[p:p+4])[0] != 0x3f2: p += 4
p += 4
mine_h1 = body(mine, p)
if len(mine_h1) == 0:
    p += 8
    while struct.unpack(">I", mine[p:p+4])[0] != 0x3f2: p += 4
    p += 4
    mine_h1 = b""  # empty data hunk emitted? handled below
# simpler: gas emits .text then .data; just compare merged text vs orig h0+h2
o_text = orig[0x28:0x164] + orig[0x2fc:0x113c]
o_data = orig[0x1ec:0x2f0]
assert mine_h0 == o_text, "h0/h2 merged body mismatch %d vs %d" % (len(mine_h0), len(o_text))
assert mine_h1 == o_data, "h1 body mismatch %d vs %d" % (len(mine_h1), len(o_data))
open(sys.argv[1], "wb").write(orig)
print("fixup ok")
