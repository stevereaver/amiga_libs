#!/usr/bin/env python3
# fixup.py -- post-process GNU ld hunk output to match the original
# muispecial.library 19.11 byte layout:
#   * rewrite hunk0 RELOC32 groups with the original offset ordering
#     (both groups stored in descending order by the original linker)
#   * flip hunk1's emitted HUNK_CODE tag to HUNK_DATA
# Usage: fixup.py <target> <original>
import sys, struct

H0_RELS = [0x9a4, 0x9a0, 0x99c, 0x998, 0x994, 0x990, 0x98c, 0x988,
           0x100, 0x72, 0x6e, 0x6a, 0x62, 0x5e]
H1_RELS = [0x878, 0x592, 0x3d2, 0x3ba, 0x3a4, 0x38c, 0x310, 0x2a2, 0x278]

def main():
    tgt, orig = sys.argv[1], sys.argv[2]
    d = bytearray(open(tgt, 'rb').read())
    o = open(orig, 'rb').read()

    # header: 3f3, names=0, nhunks=2, first=0, last=1, sizes
    assert int.from_bytes(d[:4], 'big') == 0x3f3
    off = 8
    nh = int.from_bytes(d[off:off+4], 'big'); off += 4
    off += 4  # first
    last = int.from_bytes(d[off:off+4], 'big'); off += 4
    sizes = [int.from_bytes(d[off+4*i:off+4*i+4], 'big') for i in range(last+1)]
    off += 4 * (last + 1)

    # hunk0 tag+size then body
    assert int.from_bytes(d[off:off+4], 'big') == 0x3e9, hex(off)
    h0size = (int.from_bytes(d[off+4:off+8], 'big') & 0x3fffffff) * 4
    off += 8
    h0body = off
    off += h0size

    # rewrite hunk0 reloc block
    assert int.from_bytes(d[off:off+4], 'big') == 0x3ec, hex(off)
    p = off + 4
    def grp(offs, hunk):
        out = struct.pack('>I', len(offs)) + struct.pack('>I', hunk)
        out += b''.join(struct.pack('>I', x) for x in offs)
        return out
    block = grp(H0_RELS, 0) + grp(H1_RELS, 1) + struct.pack('>I', 0)
    d[p:p+len(block)] = block
    off = p + len(block)

    # hunk0 END
    assert int.from_bytes(d[off:off+4], 'big') == 0x3f2, hex(off)
    off += 4

    # hunk1: GNU emits CODE tag for .h1; original is DATA
    assert int.from_bytes(d[off:off+4], 'big') == 0x3e9, hex(off)
    d[off:off+4] = (0x3ea).to_bytes(4, 'big')
    h1size = (int.from_bytes(d[off+4:off+8], 'big') & 0x3fffffff) * 4
    off += 8 + h1size
    assert int.from_bytes(d[off:off+4], 'big') == 0x3f2
    off += 4
    assert off == len(d)

    open(tgt, 'wb').write(d)
    d2 = open(tgt, 'rb').read()
    if d2 != o:
        for i, (x, y) in enumerate(zip(d2, o)):
            if x != y:
                print('mismatch @%x: %02x vs %02x' % (i, x, y))
                break
        print('FAIL: %d vs %d bytes' % (len(d2), len(o)))
        sys.exit(1)
    print('byte-identical (%d bytes)' % len(d2))

main()
