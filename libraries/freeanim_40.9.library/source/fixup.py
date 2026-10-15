#!/usr/bin/env python3
"""Rewrite the RELOC32 group in freeanim.library to the original's order."""
import struct, sys

ORDER = [0x60, 0x0a, 0x88, 0x76, 0x5c, 0x58, 0x1a, 0x16, 0x12, 0x06]

def main():
    p = sys.argv[1] if len(sys.argv) > 1 else 'freeanim.library'
    d = bytearray(open(p, 'rb').read())
    # locate the 0x3ec reloc block (immediately follows the hunk body)
    off = d.find(b'\x00\x00\x03\xec')
    assert off > 0
    n = struct.unpack('>I', d[off+4:off+8])[0]
    hunk = struct.unpack('>I', d[off+8:off+12])[0]
    assert n == len(ORDER) and hunk == 0, (n, hunk)
    cur = [struct.unpack('>I', d[off+12+i*4:off+16+i*4])[0] for i in range(n)]
    assert sorted(cur) == sorted(ORDER), cur
    for i, o in enumerate(ORDER):
        d[off+12+i*4:off+16+i*4] = struct.pack('>I', o)
    open(p, 'wb').write(d)

if __name__ == '__main__':
    main()
