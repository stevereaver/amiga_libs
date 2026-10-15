#!/usr/bin/env python3
# fixup.py -- post-link fixup for 68030.library 40.1 (MMU).
#
# The shipped binary's HUNK_RELOC32 (0x3ec) offset lists are in the
# original multi-object link order, not ascending:
#   code hunk: hunk0 [0x424,0x27e,0x278,0x6]
#              hunk1 [0x444,0x284,0x290,0x29c,0x12,0x16,0x1a,0x86,
#                     0x8e,0xa6,0xba,0xd6,0xf6]
#   data hunk: hunk0 [0x1c4..0x1f4 step 8,0x174,0x180,0xc..0xa0 step 4]
#              hunk1 [0x4]
# GNU ld emits the same (hunk,offset-set) groups sorted ascending.
# We verify the sets are identical and then splice the original's
# RELOC32 tail in place, preserving its exact order.
import struct, sys

def find_reloc32(d):
    """Return list of (tag_off, section_end) for every RELOC32 section."""
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
            raise SystemExit('fixup: unknown hunk tag %#x @ %#x' % (t, pos))
    return out

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

def main(mine, ref):
    d = bytearray(open(mine, 'rb').read())
    r = open(ref, 'rb').read()
    my_relocs = find_reloc32(d)
    ref_relocs = find_reloc32(r)
    assert len(my_relocs) == len(ref_relocs), \
        'reloc section count mismatch: %d vs %d' % (len(my_relocs), len(ref_relocs))
    # same offset sets and same section length -> plain in-place splice
    for (m_off, m_end), (r_off, r_end) in zip(reversed(my_relocs),
                                              reversed(ref_relocs)):
        g_m = reloc32_groups(d, m_off)[0]
        g_r = reloc32_groups(r, r_off)[0]
        assert len(g_m) == len(g_r), 'reloc group count mismatch'
        for (hn_m, offs_m), (hn_r, offs_r) in zip(g_m, g_r):
            assert hn_m == hn_r, 'target hunk mismatch'
            assert sorted(offs_m) == sorted(offs_r), \
                'reloc offset set mismatch: %s vs %s' % (offs_m, offs_r)
        assert m_end - m_off == r_end - r_off, 'reloc section size mismatch'
        d[m_off:m_end] = r[r_off:r_end]
    open(mine, 'wb').write(bytes(d))

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
