#!/usr/bin/env python3
"""fixup.py -- restore the original lh.library RELOC32 order.

The linker emits the relocation list in ascending offset order.  The
original binary carries a single RELOC32 group (target hunk 0) with the
two code relocs (0x206, 0x1ee) listed FIRST, followed by the header/
table relocs ascending.  Rewrite the group's offset list to match.
"""
import struct, sys

# original relocation order (single group, target hunk 0)
WANT = [0x206, 0x1ee, 0x6, 0xa, 0x12, 0x16, 0x1a, 0x98, 0x9c, 0xa0,
        0xa4, 0xa8, 0xac, 0xb0, 0xb4, 0xb8, 0xbc, 0xc0, 0xce, 0xe0, 0xee]

def main(fn):
    d = bytearray(open(fn, 'rb').read())
    # find RELOC32 (0x3ec) after the CODE hunk body
    pos = 4
    while struct.unpack('>I', d[pos:pos+4])[0] != 0:
        pos += 4
    pos += 4
    nl = struct.unpack('>I', d[pos:pos+4])[0]; pos += 4
    pos += 8 + 4*nl
    tag, sz = struct.unpack('>II', d[pos:pos+8]); pos += 8
    assert tag == 0x3e9
    pos += sz * 4
    tag = struct.unpack('>I', d[pos:pos+4])[0]
    assert tag == 0x3ec
    # rewrite: RELOC32, count, target, offsets, count-0, HUNK_END
    out = d[:pos]
    out += struct.pack('>III', 0x3ec, len(WANT), 0)
    out += struct.pack('>%dI' % len(WANT), *WANT)
    out += struct.pack('>II', 0, 0x3f2)
    open(fn, 'wb').write(out)

if __name__ == '__main__':
    main(sys.argv[1])
