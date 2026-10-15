#!/usr/bin/env python3
# fixup.py -- post-link fixup for xpkRLEN.library 1.3.
#
# The shipped binary's HUNK_RELOC32 offset groups are stored in a
# scrambled order: three ascending sub-runs (one per emitting source
# region), each reversed, the groups concatenated back-to-front.  GNU
# ld emits the same offsets as one ascending list, so we rewrite each
# group's entries to the reference binary's exact permutation
# (the offset SET is identical; only order differs).
import struct, sys

def groups(d, o):
    """Parse a HUNK_RELOC32 section starting at file offset o.
    Returns list of (group_file_offset, hunk, [offsets])."""
    out = []
    while True:
        n = struct.unpack('>I', d[o:o+4])[0]; o += 4
        if n == 0:
            break
        hn = struct.unpack('>I', d[o:o+4])[0]; o += 4
        offs = [struct.unpack('>I', d[o+4*j:o+4*j+4])[0]
                for j in range(n)]
        out.append((o, hn, offs))
        o += 4 * n
    return out

def reloc_sections(d):
    """Yield the file offset of each HUNK_RELOC32 section."""
    nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
    o = 0x14 + 4 * nh
    while o < len(d) - 4:
        tag = struct.unpack('>I', d[o:o+4])[0]
        o += 4
        if tag == 0x3ec:
            yield o
            while True:
                n = struct.unpack('>I', d[o:o+4])[0]; o += 4
                if n == 0:
                    break
                o += 4 + 4 * n     # skip hunk-index long + n offsets
        elif tag in (0x3e9, 0x3ea, 0x3eb, 0x3f0):
            sz = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff
            o += 4 + sz * 4
        elif tag in (0x3f2, 0):
            continue               # HUNK_END / pad: keep scanning
        elif tag == 0x3f3:
            break                  # another HUNK_HEADER: stop
        else:
            raise SystemExit('fixup: unknown hunk tag %x' % tag)

def main(mine, ref):
    d = bytearray(open(mine, 'rb').read())
    r = open(ref, 'rb').read()
    for o_m, o_r in zip(reloc_sections(d), reloc_sections(r)):
        g_m = groups(d, o_m)
        g_r = groups(r, o_r)
        assert len(g_m) == len(g_r), 'reloc group count mismatch'
        for (pos, hn_m, offs_m), (_, hn_r, offs_r) in zip(g_m, g_r):
            assert hn_m == hn_r, 'hunk index mismatch'
            assert sorted(offs_m) == sorted(offs_r), \
                'reloc offset set mismatch: %s vs %s' % (offs_m, offs_r)
            for j, v in enumerate(offs_r):
                struct.pack_into('>I', d, pos + 4*j, v)
    open(mine, 'wb').write(bytes(d))

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
