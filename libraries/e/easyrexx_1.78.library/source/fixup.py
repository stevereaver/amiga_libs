#!/usr/bin/env python3
# Rewrite GNU ld's RELOC32 records into the original producer's exact
# (descending-then-ascending) offset ordering, and verify byte-exactness.
import struct, sys

tgt = sys.argv[1] if len(sys.argv) > 1 else 'easyrexx.library'
orig = sys.argv[2] if len(sys.argv) > 2 else '../binary/easyrexx_1.78.library'

REL0_0 = [0xa14,0xa10,0xa0c,0xa08,0xa04,0xa00,0x9fc,0x9f8,0x9f4,0x9f0,
          0x9ec,0x9e8,0x9e4,0x9e0,0x9dc,0x9d8,0x9d4,0x5a,0x34,0x16,
          0x12,0xa,0x6]
REL0_1 = [0xa9c,0xa80,0xa68,0xa50,0x86,0x74,0x1a]
REL1_0 = [0x8,0x10]

d = open(tgt, 'rb').read()
assert d[:4] == b'\x00\x00\x03\xf3'
o = 0x1c
bodies, tags, rels = [], [], {}
hi = -1
while o < len(d):
    tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
    if tag in (0x3e9, 0x3ea):
        n = struct.unpack('>I', d[o:o+4])[0] * 4; o += 4
        bodies.append(d[o:o+n]); o += n
        tags.append(tag); hi += 1
        rels[hi] = {}
    elif tag == 0x3ec:
        while True:
            c = struct.unpack('>I', d[o:o+4])[0]; o += 4
            if c == 0:
                break
            t = struct.unpack('>I', d[o:o+4])[0]; o += 4
            rels[hi][t] = list(struct.unpack('>%dI' % c, d[o:o+4*c])); o += 4*c
    elif tag == 0x3f2:
        pass
    else:
        break

assert sorted(rels[0].get(0, [])) == sorted(REL0_0), rels[0]
assert sorted(rels[0].get(1, [])) == sorted(REL0_1)
assert sorted(rels[1].get(0, [])) == sorted(REL1_0)
assert len(bodies) == 2 and len(bodies[0]) == 0x2b5*4 and len(bodies[1]) == 24

out = bytearray()
out += struct.pack('>7I', 0x3f3, 0, 2, 0, 1, 0x2b5, 0x06)
out += struct.pack('>2I', 0x3e9, 0x2b5) + bodies[0]
out += struct.pack('>I', 0x3ec)
for rel, t in ((REL0_0, 0), (REL0_1, 1)):
    out += struct.pack('>2I', len(rel), t) + struct.pack('>%dI' % len(rel), *rel)
out += struct.pack('>I', 0)
out += struct.pack('>I', 0x3f2)
out += struct.pack('>2I', 0x3ea, 6) + bodies[1]
out += struct.pack('>I', 0x3ec)
out += struct.pack('>2I', len(REL1_0), 0) + struct.pack('>2I', *REL1_0)
out += struct.pack('>I', 0)
out += struct.pack('>I', 0x3f2)
open(tgt, 'wb').write(out)

if len(sys.argv) > 2:
    o = open(orig, 'rb').read()
    if o == out:
        print('BYTE-IDENTICAL', tgt)
    else:
        print('size %d vs %d' % (len(out), len(o)))
        for i in range(min(len(o), len(out))):
            if o[i] != out[i]:
                print('first diff @%x: %02x vs %02x' % (i, o[i], out[i]))
                break
        sys.exit(1)
else:
    print('wrote %d bytes' % len(out))
