#!/usr/bin/env python3
# Post-link fixup for mathieeesingbas.library "MSB 10.881".
# GNU ld emits a long-format HUNK_RELOC32 (0x3ec) tail; the shipped
# binary carries the compact 16-bit form (0x3f7, RELOC32SHORT/DREL16)
# with the 8 RomTag/InitTable refs in descending offset order.
# Rebuild the file in the original layout and verify byte-identity
# against binary/ mathieeesingbas_10.881(UAE).library.
import struct, sys, hashlib

HUNK_HEADER  = 0x3f3
HUNK_CODE    = 0x3e9
HUNK_RELOC32 = 0x3ec
HUNK_REL16S  = 0x3f7
HUNK_END     = 0x3f2

# Original relocation group: (hunk, [offsets in original order])
ORIG = [(0, [0x28, 0x24, 0x20, 0x18, 0x14, 0x10, 0x08, 0x04])]

def main():
    target, origpath = sys.argv[1], sys.argv[2]
    d = open(target, 'rb').read()
    assert struct.unpack('>I', d[0:4])[0] == HUNK_HEADER, 'not a hunk file'
    nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
    assert nh == 1, 'expected single-hunk ld output'
    o = 0x14 + 4 * nh
    tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
    assert tag == HUNK_CODE
    sz = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff; o += 4
    assert sz == 0x72, hex(sz)
    body = d[o:o + sz*4]; o += sz*4
    t = struct.unpack('>I', d[o:o+4])[0]; o += 4
    assert t == HUNK_RELOC32, hex(t)
    got = []
    while True:
        n = struct.unpack('>I', d[o:o+4])[0]; o += 4
        if n == 0:
            break
        hn = struct.unpack('>I', d[o:o+4])[0]; o += 4
        for j in range(n):
            got.append((hn, struct.unpack('>I', d[o:o+4])[0])); o += 4
    assert sorted(got) == sorted(
        (h, x) for h, l in ORIG for x in l), got

    # emit 0x3f7: [cnt:w][hunk:w][off:w]* + cnt-0 terminator, pad to 4
    rel = b''
    for hn, offs in ORIG:
        rel += struct.pack('>HH', len(offs), hn)
        for x in offs:
            rel += struct.pack('>H', x)
    rel += b'\x00\x00'
    if len(rel) % 4:
        rel += b'\x00\x00'

    out = struct.pack('>6I', HUNK_HEADER, 0, 1, 0, 0, sz)
    out += struct.pack('>2I', HUNK_CODE, sz) + body
    out += struct.pack('>I', HUNK_REL16S) + rel
    out += struct.pack('>I', HUNK_END)

    orig = open(origpath, 'rb').read()
    if out != orig:
        n = min(len(out), len(orig))
        diff = next((k for k in range(n) if out[k] != orig[k]), n)
        print('MISMATCH: len %d vs %d, first diff @0x%x' % (
            len(out), len(orig), diff))
        sys.exit(1)
    open(target, 'wb').write(out)
    print('byte-identical: %s' % hashlib.md5(out).hexdigest())

main()
