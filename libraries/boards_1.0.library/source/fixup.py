#!/usr/bin/env python3
# Rewrite GNU ld's HUNK_RELOC32 tail into the original's DREL16 (0x3f7)
# format with the original producer's exact descending offset order.
import struct, sys

tgt  = sys.argv[1] if len(sys.argv) > 1 else 'boards.library'
orig = sys.argv[2] if len(sys.argv) > 2 else '../binary/boards_1.0.library'

# original relocation order (descending, from binary analysis)
REL0 = [0x13c,0x120,0x110,0x0fe,0x0f0,0x0ec,0x0e8,0x0e4,0x0e0,0x0dc,
        0x0d8,0x0d4,0x01a,0x016,0x012,0x00a,0x006]

d = open(tgt, 'rb').read()
assert d[:4] == b'\x00\x00\x03\xf3'
o = 0x18
bodies, rels = [], {}
while o < len(d):
    tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
    if tag in (0x3e9, 0x3ea):
        n = struct.unpack('>I', d[o:o+4])[0] * 4; o += 4
        bodies.append(d[o:o+n]); o += n
    elif tag == 0x3ec:
        while True:
            c = struct.unpack('>I', d[o:o+4])[0]; o += 4
            if c == 0:
                break
            t = struct.unpack('>I', d[o:o+4])[0]; o += 4
            rels[t] = list(struct.unpack('>%dI' % c, d[o:o+4*c])); o += 4*c
    elif tag == 0x3f2:
        pass
    else:
        break

assert len(bodies) == 1 and len(bodies[0]) == 0x200
assert sorted(rels.get(0, [])) == sorted(REL0), (rels.get(0), REL0)

out = bytearray()
out += struct.pack('>6I', 0x3f3, 0, 1, 0, 0, 0x80)
out += struct.pack('>2I', 0x3e9, 0x80) + bodies[0]
out += struct.pack('>I', 0x3f7)
out += struct.pack('>HH', len(REL0), 0) + struct.pack('>%dH' % len(REL0), *REL0)
out += struct.pack('>H', 0)          # DREL16 word-0 terminator
out += struct.pack('>I', 0x3f2)      # HUNK_END
open(tgt, 'wb').write(out)

exp = open(orig, 'rb').read()
if bytes(out) == exp:
    print('BYTE-IDENTICAL')
else:
    print('MISMATCH: %d vs %d bytes' % (len(out), len(exp)))
    for i in range(min(len(out), len(exp))):
        if out[i] != exp[i]:
            print('first diff @%x: %02x vs %02x' % (i, out[i], exp[i]))
            break
