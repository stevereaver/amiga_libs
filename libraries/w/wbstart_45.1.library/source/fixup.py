#!/usr/bin/env python3
# fixup.py -- post-link fixup for wbstart.library 45.1.
#
# The shipped binary stores the DATA hunk's relocations as
# HUNK_DREL32 (0x3f7): u16 count / u16 target-hunk records with
# u16 offsets, closed by a single 0x0000 terminator word:
#   {7,hunk0: 00 04 08 0c 10 14 58} {6,hunk1: 50 5e 62 6a 6e 72} 0000
# GNU ld emits the same relocation set as HUNK_RELOC32 (0x3ec, long
# offsets).  We verify the two encodings describe identical
# (hunk,offset-set) groups and then splice the original's DREL32
# tail in place of our RELOC32 tail, preserving its exact order.
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

def main(mine, ref):
    d = bytearray(open(mine, 'rb').read())
    r = open(ref, 'rb').read()
    my_relocs = find_reloc(d, 0x3ec)
    ref_relocs = find_reloc(r, 0x3f7)
    assert len(my_relocs) == len(ref_relocs), \
        'reloc section count mismatch: %d vs %d' % (len(my_relocs), len(ref_relocs))
    # walk from the last section backwards so earlier offsets stay valid
    for (m_off, m_end), (r_off, r_end) in zip(reversed(my_relocs),
                                              reversed(ref_relocs)):
        g_m = reloc32_groups(d, m_off)[0]
        g_r = drel32_groups(r, r_off)[0]
        assert len(g_m) == len(g_r), 'reloc group count mismatch'
        for (hn_m, offs_m), (hn_r, offs_r) in zip(g_m, g_r):
            assert hn_m == hn_r, 'target hunk mismatch'
            assert sorted(offs_m) == sorted(offs_r), \
                'reloc offset set mismatch: %s vs %s' % (offs_m, offs_r)
        d[m_off:m_end] = r[r_off:r_end]
    open(mine, 'wb').write(bytes(d))

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
