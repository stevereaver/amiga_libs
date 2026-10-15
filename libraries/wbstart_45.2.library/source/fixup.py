#!/usr/bin/env python3
# fixup.py -- post-link fixup for wbstart.library 45.2.
#
# The shipped binary uses plain HUNK_RELOC32 (0x3ec) tails on BOTH
# hunks, but the CODE hunk's first group lists its offsets in a
# non-sorted order ({2,hunk0: 1dc 1cc}) and the group order within
# each section may differ from GNU ld's emission.  We verify that
# our linker's relocation set and the original's describe identical
# (target-hunk, offset-set) groups and then splice the original's
# RELOC32 tail in place of ours, preserving its exact byte layout.
import struct, sys

def hunk_body_spans(d):
    """Return list of (kind, tag_off, body_off, body_end, next_off)
    for CODE/DATA/BSS hunks (reloc/symbol/debug blocks sit between
    body_end and next_off; we only need the hunk header positions)."""
    nh = struct.unpack('>I', d[16:20])[0] + 1
    pos = 20 + 4 * nh
    out = []
    while pos < len(d):
        tag = struct.unpack('>I', d[pos:pos + 4])[0] & 0x3fffffff
        if tag == 0x3f3:          # another header (shouldn't happen)
            break
        if tag in (0x3e9, 0x3ea, 0x3eb):
            sz = struct.unpack('>I', d[pos + 4:pos + 8])[0] & 0x3fffffff
            out.append((tag, pos, pos + 8, pos + 8 + sz * 4))
            pos += 8 + sz * 4
            continue
        if tag == 0x3ec:          # RELOC32
            p = pos + 4
            while True:
                n = struct.unpack('>I', d[p:p + 4])[0]; p += 4
                if n == 0:
                    break
                p += 4 + 4 * n
            pos = p
            continue
        if tag == 0x3f7:          # DREL32 (word records)
            p = pos + 4
            while True:
                n = struct.unpack('>H', d[p:p + 2])[0]
                p += 4
                if n == 0:
                    pos = p - 2   # terminator word only
                    break
                p += 2 * n
            pos = p
            continue
        if tag == 0x3f2:          # HUNK_END
            pos += 4
            continue
        raise SystemExit('fixup: unknown hunk tag %#x @ %#x' % (tag, pos))
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

def drel32_groups(d, off):
    """Parse a DREL32 section at off -> ([(hunk,[offs])], end)."""
    g = []
    p = off + 4
    while True:
        n = struct.unpack('>H', d[p:p + 2])[0]
        if n == 0:
            return g, p + 2        # terminator is a lone u16 zero
        hn = struct.unpack('>H', d[p + 2:p + 4])[0]
        p += 4
        offs = list(struct.unpack('>' + str(n) + 'H', d[p:p + 2 * n]))
        p += 2 * n
        g.append((hn, offs))

def find_reloc(d, tag):
    """Return list of (tag_off, body_end) positions of reloc sections."""
    out = []
    pos = 20 + 4 * (struct.unpack('>I', d[16:20])[0] + 1)
    while pos < len(d):
        t = struct.unpack('>I', d[pos:pos + 4])[0] & 0x3fffffff
        if t in (0x3e9, 0x3ea, 0x3eb):
            sz = struct.unpack('>I', d[pos + 4:pos + 8])[0] & 0x3fffffff
            pos += 8 + sz * 4
        elif t == tag:
            if t == 0x3ec:
                _, end = reloc32_groups(d, pos)
            else:
                _, end = drel32_groups(d, pos)
            out.append((pos, end))
            pos = end
        elif t == 0x3f2:
            pos += 4
        else:
            raise SystemExit('fixup: unknown tag %#x @ %#x' % (t, pos))
    return out

def groups_of(d, tag, off):
    return reloc32_groups(d, off)[0] if tag == 0x3ec \
        else drel32_groups(d, off)[0]

def main(mine, ref):
    d = bytearray(open(mine, 'rb').read())
    r = open(ref, 'rb').read()
    my_relocs = find_reloc(d, 0x3ec)
    # shipped tail is RELOC32; keep DREL32 branch for safety
    ref_relocs = find_reloc(r, 0x3ec) or find_reloc(r, 0x3f7)
    ref_tag = 0x3ec if find_reloc(r, 0x3ec) else 0x3f7
    assert len(my_relocs) == len(ref_relocs), \
        'reloc section count mismatch: %d vs %d' % (len(my_relocs), len(ref_relocs))
    # walk from the last section backwards so earlier offsets stay valid
    for (m_off, m_end), (r_off, r_end) in zip(reversed(my_relocs),
                                              reversed(ref_relocs)):
        g_m = groups_of(d, 0x3ec, m_off)
        g_r = groups_of(r, ref_tag, r_off)
        assert len(g_m) == len(g_r), 'reloc group count mismatch'
        for (hn_m, offs_m), (hn_r, offs_r) in zip(g_m, g_r):
            assert hn_m == hn_r, 'target hunk mismatch'
            assert sorted(offs_m) == sorted(offs_r), \
                'reloc offset set mismatch: %s vs %s' % (offs_m, offs_r)
        d[m_off:m_end] = r[r_off:r_end]
    open(mine, 'wb').write(bytes(d))

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
