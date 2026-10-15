#!/usr/bin/env python3
"""xpkNONE 1.4: GNU ld emits an ascending RELOC32 group; the shipped
binary's 28-entry tail is in a scrambled descending order (island ptrs
0x1ea..0x1b6 first, then functab/romtag/inittab/datatab interleaved).
Rebuilds the tail verbatim, then verifies byte-identity."""
import struct, sys, hashlib

ORIG_OFFSETS = [0x1ea, 0x1e2, 0x1de, 0x1da, 0x1d6, 0x1be, 0x1ba, 0x1b6,
                0x24, 0x18, 0x14, 0x9a, 0x96, 0x92, 0x8a, 0x86, 0x80,
                0x7c, 0x78, 0x6c, 0x5a, 0x28, 0x20, 0x1c, 0x10, 0xc, 0x8, 0x4]

def main(path, orig):
    d = open(path, 'rb').read()
    o = d.index(b'\x00\x00\x03\xec')
    n = struct.unpack('>L', d[o+4:o+8])[0]
    assert struct.unpack('>L', d[o+8:o+12])[0] == 0   # hunk 0
    end = struct.unpack('>L', d[o+12+4*n:o+16+4*n])[0]
    assert end == 0                                   # group terminator
    tail = struct.pack('>LLL', 0x3ec, len(ORIG_OFFSETS), 0)
    tail += b''.join(struct.pack('>L', x) for x in ORIG_OFFSETS)
    tail += struct.pack('>LL', 0, 0x3f2)
    out = d[:o] + tail
    open(path, 'wb').write(out)
    od = open(orig, 'rb').read()
    if out == od:
        print('byte-identical:', hashlib.md5(out).hexdigest())
    else:
        for i in range(min(len(out), len(od))):
            if out[i] != od[i]:
                print('diff @%#x: %02x vs %02x' % (i, od[i], out[i])); break
        print('len', len(od), 'vs', len(out)); sys.exit(1)

main(sys.argv[1], '../binary/xpkNONE_1.4.library')
