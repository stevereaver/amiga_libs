#!/usr/bin/env python3
# Post-link fixup for cyberlayers.library 40.8.
# GNU ld emits plain RELOC32 records; the original used compact
# RELOC32SHORT records. Rebuild the whole hunk file in the original
# format and verify byte-identity against the original binary.
import struct, sys, hashlib

HUNK_HEADER  = 0x3f3
HUNK_CODE    = 0x3e9
HUNK_RELOC32 = 0x3ec
HUNK_REL16S  = 0x3f7
HUNK_END     = 0x3f2

# Original relocation groups, in original order.
ORIG = [
    # hunk 0
    [(0, [0x6, 0x12, 0x16, 0x1a, 0xc6, 0xca, 0xce, 0xe4, 0xf6, 0x4ac]),
     (1, [0xa, 0x48e, 0x494, 0x49a, 0x4a0, 0x4a6])],
    # hunk 1: none
    [],
]

def parse(path):
    d = open(path, 'rb').read()
    assert struct.unpack('>I', d[0:4])[0] == HUNK_HEADER, 'not a hunk file'
    nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
    o = 0x14 + 4 * nh
    hunks = []
    for i in range(nh):
        tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
        assert tag == HUNK_CODE, 'hunk %d tag %x' % (i, tag)
        sz = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff; o += 4
        body = d[o:o + sz*4]; o += sz * 4
        relocs = []
        while True:
            t = struct.unpack('>I', d[o:o+4])[0]; o += 4
            if t == HUNK_RELOC32:
                while True:
                    n = struct.unpack('>I', d[o:o+4])[0]; o += 4
                    if n == 0:
                        break
                    hn = struct.unpack('>I', d[o:o+4])[0]; o += 4
                    for j in range(n):
                        relocs.append((hn, struct.unpack(
                            '>I', d[o+4*j:o+4+4*j])[0]))
                    o += 4 * n
            elif t == HUNK_END:
                break
            else:
                raise Exception('tag %x at %x in hunk %d' % (t, o-4, i))
        hunks.append((sz, body, relocs))
    return hunks

def emit_short(groups):
    """Emit RELOC32SHORT body: [cnt:w][hunk:w][off:w...]* 0:w, pad to 4."""
    out = b''
    for hn, offs in groups:
        out += struct.pack('>HH', len(offs), hn)
        for x in offs:
            out += struct.pack('>H', x)
    out += b'\x00\x00'                     # count-0 terminator
    if len(out) % 4:
        out += b'\x00\x00'                 # pad to longword
    return out

def main():
    target, origpath = sys.argv[1], sys.argv[2]
    hunks = parse(target)
    assert len(hunks) == 2, 'expected 2 hunks'
    for i, (sz, body, relocs) in enumerate(hunks):
        want = sorted((h, x) for h, l in ORIG[i] for x in l)
        assert sorted(relocs) == want, 'hunk %d reloc mismatch: %s' % (
            i, sorted(set(relocs) ^ set(want)))
    # rebuild file
    out = struct.pack('>IIIIIII', HUNK_HEADER, 0, 2, 0, 1,
                      hunks[0][0], hunks[1][0])
    for i, (sz, body, relocs) in enumerate(hunks):
        out += struct.pack('>II', HUNK_CODE, sz) + body
        if ORIG[i]:
            out += struct.pack('>I', HUNK_REL16S) + emit_short(ORIG[i])
        out += struct.pack('>I', HUNK_END)
    orig = open(origpath, 'rb').read()
    if out != orig:
        n = min(len(out), len(orig))
        diff = next((k for k in range(n) if out[k] != orig[k]), n)
        print('MISMATCH: len %d vs %d, first diff @0x%x (%02x vs %02x)' % (
            len(out), len(orig), diff,
            out[diff] if diff < len(out) else -1,
            orig[diff] if diff < len(orig) else -1))
        sys.exit(1)
    open(target, 'wb').write(out)
    print('byte-identical: %s' % hashlib.md5(out).hexdigest())

main()
