#!/usr/bin/env python3
# fixup.py -- post-link fixup for mhimpegit.library 1.2.
#
# The shipped binary stores each hunk's HUNK_RELOC32 offset groups in
# DESCENDING order (hunk0: one group of 14 into hunk1; hunk1: one
# group of 15 into hunk0 then one group of 4 self-relocs).  GNU ld
# emits the same sets in ascending order (and may emit the hunk1
# groups target-first differently).  We verify that, per hunk tail,
# the multiset of (target-hunk, offset) pairs is identical and then
# splice the reference binary's whole RELOC32 tail over ours.
import struct, sys

def reloc32_groups(d, off):
    """Parse a RELOC32 section at off -> ([(hunk,[offs])], end)."""
    g = []
    p = off + 4
    while True:
        n = struct.unpack('>I', d[p:p + 4])[0]; p += 4
        if n == 0:
            return g, p
        hn = struct.unpack('>I', d[p:p + 4])[0]; p += 4
        offs = list(struct.unpack('>' + str(n) + 'I', d[p:p + 4 * n]))
        p += 4 * n
        g.append((hn, offs))

def find_reloc32(d):
    """Return list of (tag_off, end) positions of RELOC32 sections."""
    out = []
    pos = 20 + 4 * (struct.unpack('>I', d[16:20])[0] + 1)
    while pos < len(d):
        t = struct.unpack('>I', d[pos:pos + 4])[0] & 0x3fffffff
        if t in (0x3e9, 0x3ea, 0x3eb):
            sz = struct.unpack('>I', d[pos + 4:pos + 8])[0] & 0x3fffffff
            pos += 8 + sz * 4
        elif t == 0x3ec:
            _, end = reloc32_groups(d, pos)
            out.append((pos, end))
            pos = end
        elif t == 0x3f2:
            pos += 4
        else:
            raise SystemExit('fixup: unknown tag %#x @ %#x' % (t, pos))
    return out

def main(mine, ref):
    d = bytearray(open(mine, 'rb').read())
    r = open(ref, 'rb').read()
    my_relocs = find_reloc32(d)
    ref_relocs = find_reloc32(r)
    assert len(my_relocs) == len(ref_relocs), \
        'reloc section count mismatch: %d vs %d' % (
            len(my_relocs), len(ref_relocs))
    # walk from the last section backwards so earlier offsets stay valid
    for (m_off, m_end), (r_off, r_end) in zip(reversed(my_relocs),
                                              reversed(ref_relocs)):
        g_m = reloc32_groups(d, m_off)[0]
        g_r = reloc32_groups(r, r_off)[0]
        set_m = sorted((hn, o) for hn, offs in g_m for o in offs)
        set_r = sorted((hn, o) for hn, offs in g_r for o in offs)
        assert set_m == set_r, \
            'reloc set mismatch: %s vs %s' % (set_m, set_r)
        assert m_end - m_off == r_end - r_off, \
            'reloc tail size mismatch: %d vs %d' % (m_end - m_off,
                                                  r_end - r_off)
        d[m_off:m_end] = r[r_off:r_end]
    open(mine, 'wb').write(bytes(d))

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
