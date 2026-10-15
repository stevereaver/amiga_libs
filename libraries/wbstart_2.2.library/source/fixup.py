#!/usr/bin/env python3
# fixup.py -- post-link fixup for wbstart.library 2.2.
#
# The shipped binary has:
#   - hunk table entry for hunk 1 = 0xa longs (40 bytes alloc)
#     while the DATA hunk body defines only 1 long (4 bytes).
#     GNU ld writes alloc==body, so the size word is patched.
#   - a plain HUNK_RELOC32 tail on the CODE hunk whose groups
#     list offsets in non-sorted order ({5c 58 64 68 6c 70 74
#     78 80 7c 84 d0 a0 90 408} -> hunk0); GNU ld sorts them.
# We verify that our linker's relocation set matches the
# original's (same target-hunk, same offset set per group),
# then splice the original's RELOC32 tail in place of ours and
# copy the hunk table verbatim.
import struct, sys

def parse(d):
    """Return (nhunks, sizes_off, hunks=[(tag,tag_off,body_off,body_end)],
    tail blocks keyed by position)."""
    nh = struct.unpack('>I', d[16:20])[0] + 1
    pos = 20 + 4 * nh
    hunks = []
    extra = []   # (kind, start, end) for reloc/end blocks
    while pos < len(d):
        tag = struct.unpack('>I', d[pos:pos + 4])[0] & 0x3fffffff
        if tag in (0x3e9, 0x3ea, 0x3eb):
            sz = struct.unpack('>I', d[pos + 4:pos + 8])[0] & 0x3fffffff
            hunks.append((tag, pos, pos + 8, pos + 8 + sz * 4))
            pos += 8 + sz * 4
            continue
        if tag == 0x3ec:
            p = pos + 4
            while True:
                n = struct.unpack('>I', d[p:p + 4])[0]; p += 4
                if n == 0:
                    break
                p += 4 + 4 * n
            extra.append((tag, pos, p))
            pos = p
            continue
        if tag == 0x3f7:
            p = pos + 4
            while True:
                n = struct.unpack('>H', d[p:p + 2])[0]
                p += 4
                if n == 0:
                    p -= 2
                    break
                p += 2 * n
            extra.append((tag, pos, p))
            pos = p
            continue
        if tag == 0x3f2:
            extra.append((tag, pos, pos + 4))
            pos += 4
            continue
        if tag == 0x3f0:            # HUNK_SYMBOL (should not appear w/ -s)
            p = pos + 4
            while True:
                n = struct.unpack('>I', d[p:p + 4])[0]; p += 4
                if n == 0:
                    break
                p += 4 * n + 4
            extra.append((tag, pos, p))
            pos = p
            continue
        raise SystemExit('fixup: unknown hunk tag %#x @ %#x' % (tag, pos))
    return nh, hunks, extra

def reloc_groups(d, off):
    """RELOC32 section at off -> [(hunk,[offsets])]."""
    g = []
    p = off + 4
    while True:
        n = struct.unpack('>I', d[p:p + 4])[0]; p += 4
        if n == 0:
            return g
        hn = struct.unpack('>I', d[p:p + 4])[0]; p += 4
        offs = list(struct.unpack('>' + str(n) + 'I', d[p:p + 4 * n]))
        p += 4 * n
        g.append((hn, offs))

def reloc_set(d):
    """Set of (hunk_index_of_section_being_relocated, target_hunk, off)."""
    _, hunks, extra = parse(d)
    out = set()
    hi = -1
    for tag, s, e in extra:
        pass
    # walk order: hunks and extras interleaved; reloc block belongs to
    # the hunk whose body precedes it.
    nh = struct.unpack('>I', d[16:20])[0] + 1
    pos = 20 + 4 * nh
    cur = -1
    while pos < len(d):
        tag = struct.unpack('>I', d[pos:pos + 4])[0] & 0x3fffffff
        if tag in (0x3e9, 0x3ea, 0x3eb):
            cur += 1
            sz = struct.unpack('>I', d[pos + 4:pos + 8])[0] & 0x3fffffff
            pos += 8 + sz * 4
        elif tag == 0x3ec:
            for hn, offs in reloc_groups(d, pos):
                for o in offs:
                    out.add((cur, hn, o))
            p = pos + 4
            while True:
                n = struct.unpack('>I', d[p:p + 4])[0]; p += 4
                if n == 0:
                    break
                p += 4 + 4 * n
            pos = p
        elif tag == 0x3f2:
            pos += 4
        elif tag == 0x3f0:
            p = pos + 4
            while True:
                n = struct.unpack('>I', d[p:p + 4])[0]; p += 4
                if n == 0:
                    break
                p += 4 * n + 4
            pos = p
        else:
            raise SystemExit('fixup: unknown tag %#x @ %#x' % (tag, pos))
    return out

def main(mine, ref):
    d = open(mine, 'rb').read()
    r = open(ref, 'rb').read()

    m_nh, m_hunks, m_extra = parse(d)
    r_nh, r_hunks, r_extra = parse(r)
    assert m_nh == r_nh == 2, (m_nh, r_nh)

    # bodies must already match byte-for-byte
    for i, ((mt, _, mb0, mb1), (rt, _, rb0, rb1)) in enumerate(
            zip(m_hunks, r_hunks)):
        assert mt == rt, 'hunk %d tag mismatch %#x vs %#x' % (i, mt, rt)
        mbody, rbody = d[mb0:mb1], r[rb0:rb1]
        assert mbody == rbody, 'hunk %d body mismatch' % i

    # relocation sets must describe the same fixups
    assert reloc_set(d) == reloc_set(r), 'reloc set mismatch'

    # rebuild: original header (incl. 0xa-long data alloc size),
    # my bodies, original tails (reloc + END + data hunk + END)
    out = bytearray()
    r_hdr_end = r_hunks[0][1]           # start of first hunk tag
    out += r[:r_hdr_end]                # HUNK_HEADER + table verbatim
    for i, ((mt, _, mb0, mb1), (_, rt_off, rb0, rb1)) in enumerate(
            zip(m_hunks, r_hunks)):
        # original hunk tag+size word, my body
        out += r[rt_off:rb0]
        out += d[mb0:mb1]
        # then all extra blocks that follow this hunk in the original
        end = rb1
        while True:
            tag = struct.unpack('>I', r[end:end + 4])[0] & 0x3fffffff
            if tag == 0x3ec:
                p = end + 4
                while True:
                    n = struct.unpack('>I', r[p:p + 4])[0]; p += 4
                    if n == 0:
                        break
                    p += 4 + 4 * n
                out += r[end:p]; end = p
            elif tag == 0x3f7:
                p = end + 4
                while True:
                    n = struct.unpack('>H', r[p:p + 2])[0]; p += 4
                    if n == 0:
                        p -= 2; break
                    p += 2 * n
                out += r[end:p]; end = p
            elif tag in (0x3f2,):
                out += r[end:end + 4]; end += 4
                break            # HUNK_END terminates this hunk
            else:
                raise SystemExit('fixup: unexpected tag %#x' % tag)
    assert len(out) == len(r), 'size mismatch %d vs %d' % (len(out), len(r))
    open(mine, 'wb').write(bytes(out))

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
