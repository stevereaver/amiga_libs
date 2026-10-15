#!/usr/bin/env python3
"""The original's RELOC32 block lists offsets DESCENDING; GNU ld emits
them ascending. Reorder the single group in place."""
import struct, sys

def main(path, orig):
    d = open(path, 'rb').read()
    o = d.index(b'\x00\x00\x03\xec')
    n = struct.unpack('>L', d[o+4:o+8])[0]
    offs = list(struct.unpack('>%dL' % n, d[o+12:o+12+4*n]))
    assert offs == sorted(offs), offs
    out = d[:o+12] + b''.join(struct.pack('>L', x) for x in reversed(offs)) + d[o+12+4*n:]
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
