#!/usr/bin/env python3
"""Rewrite GNU ld's HUNK_RELOC32 tail into the original's compact
HUNK_RELOC32SHORT (0x3f7) block with the original relocation ordering."""
import struct, sys

ORIG = [0xa, 0x12, 0x16, 0x1a, 0xd4, 0xd8, 0xdc, 0xe0, 0xe4, 0xe8, 0xec,
        0x10c, 0xfa, 0x6]

def main(path, orig):
    d = open(path, 'rb').read()
    o = d.index(b'\x00\x00\x03\xec')
    n = struct.unpack('>L', d[o+4:o+8])[0]
    hunk = struct.unpack('>L', d[o+8:o+12])[0]
    offs = list(struct.unpack('>%dL' % n, d[o+12:o+12+4*n]))
    assert sorted(offs) == sorted(ORIG), (offs, ORIG)
    end = d.index(b'\x00\x00\x03\xf2', o)
    tail = b'\x00\x00\x03\xf7' + struct.pack('>HH', n, 0)
    tail += b''.join(struct.pack('>H', x) for x in ORIG)
    tail += b'\x00\x00'
    while len(tail) % 4:
        tail += b'\x00\x00'
    out = d[:o] + tail + d[end:]
    open(path, 'wb').write(out)
    od = open(orig, 'rb').read()
    if out == od:
        import hashlib
        print('byte-identical:', hashlib.md5(out).hexdigest())
    else:
        for i in range(min(len(out), len(od))):
            if out[i] != od[i]:
                print('diff @%#x: %02x vs %02x' % (i, od[i], out[i])); break
        print('len', len(od), 'vs', len(out)); sys.exit(1)

main(sys.argv[1], sys.argv[2])
