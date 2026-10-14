#!/usr/bin/env python3
# fixup.py -- rewrite recent.library's RELOC32 block to the original's
# exact form: {0x3ec, total=24, hunk0, count=24, offsets..., count=0},
# then HUNK_END.
import struct, sys

ORIG_OFFS = [0x6, 0xa, 0x12, 0x16, 0x1a, 0x78, 0x7c, 0x80,
             0x84, 0x88, 0x8c, 0x90, 0x94, 0x98, 0x9c, 0xa0,
             0xa4, 0xa8, 0xac, 0xb0, 0xb4, 0xc2, 0xd4, 0x7d0]

def main(path):
    d = bytearray(open(path, 'rb').read())
    # locate hunk body: HUNK_HEADER 0x3f3, names(0), tablesize, first, last, sizes
    pos = 4
    while True:
        n = struct.unpack('>I', d[pos:pos+4])[0]; pos += 4
        if n == 0: break
    ts, fh, lh = struct.unpack('>III', d[pos:pos+12]); pos += 12
    nh = lh - fh + 1
    sizes = struct.unpack('>%dI' % nh, d[pos:pos+4*nh]); pos += 4*nh
    # single CODE hunk
    tag, sz = struct.unpack('>II', d[pos:pos+8])
    assert tag == 0x3e9
    body = pos + 8
    end = body + sz*4
    # walk the trailer to its end; rewrite as: 0x3ec, 24, 0, 24, offs..., 0, 0x3f2
    # original producer emits {count, hunk, offs[count]} groups
    out = d[:end]
    out += struct.pack('>II', 0x3ec, len(ORIG_OFFS))
    out += struct.pack('>I', 0)  # hunk 0
    out += struct.pack('>%dI' % len(ORIG_OFFS), *ORIG_OFFS)
    out += struct.pack('>II', 0, 0x3f2)
    open(path, 'wb').write(bytes(out))

if __name__ == '__main__':
    main(sys.argv[1])
