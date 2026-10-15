#!/usr/bin/env python3
# Rewrite GNU ld's HUNK_RELOC32 tail into the original's DREL16 (0x3f7)
# format, with the original producer's exact offset ordering, and emit
# hunk1 as a 1-longword DATA hunk (header still allocates 16 B).
import struct, sys

tgt = sys.argv[1] if len(sys.argv) > 1 else 'mhimpegit.library'
orig = sys.argv[2] if len(sys.argv) > 2 else '../binary/mhimpegit_1.1.library'

# original relocation order (from binary analysis; GNU emits sorted lists)
REL0 = [0x20c,0x218,0x2c6,0x2ca,0x2d2,0x2d6,0x2da,0x2e0,0x2e4,0x2e8,
        0x2ec,0x324,0x33c,0x348,0x34c,0x350,0x2f0,0x2f4,0x2f8,0x2fc,
        0x300,0x304,0x308,0x30c,0x310,0x314,0x778,0x788,0x40e,0x448,
        0x462,0x470,0x47e,0x48c,0x59e,0x780,0x866,0x8be,0x914]
REL1 = [0x0a,0x1a,0x22,0x32,0x3e,0x4e,0x54,0x5e,0x66,0xa0,0xa8,0xae,
        0xb8,0xbe,0xc6,0xcc,0xd6,0xdc,0xe4,0xea,0xf4,0x122,0x148,
        0x1bc,0x1c8,0x22a,0x38e,0x3d0,0x3f0,0x44e,0x4c8,0x4de,0x4ec,
        0x4fa,0x508,0x530,0x55a,0x5da,0x5ee,0x6c6,0x6d4,0x6e2,0x39e,
        0x3a8,0x426,0x430,0x4ba,0x4c2,0x4d2,0x524,0x56c,0x5b4,0x5c0,
        0x60e,0x61a,0x63c,0x662,0x68e,0x69a,0x6aa,0x6f0,0x7e6,0x82e,
        0x886,0x8de,0x934,0x6b4]

d = open(tgt, 'rb').read()
assert d[:4] == b'\x00\x00\x03\xf3'
o = 0x1c
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

# sanity: our relocated fields must be exactly the original set
assert sorted(rels.get(0, [])) == sorted(REL0), (rels.get(0), REL0)
assert sorted(rels.get(1, [])) == sorted(REL1)
assert len(bodies) == 2 and len(bodies[0]) == 0xaa8

out = bytearray()
out += struct.pack('>7I', 0x3f3, 0, 2, 0, 1, 0x2aa, 0x04)
out += struct.pack('>2I', 0x3e9, 0x2aa) + bodies[0]
out += struct.pack('>I', 0x3f7)
out += struct.pack('>HH', len(REL0), 0) + struct.pack('>%dH' % len(REL0), *REL0)
out += struct.pack('>HH', len(REL1), 1) + struct.pack('>%dH' % len(REL1), *REL1)
out += struct.pack('>I', 0)
out += struct.pack('>I', 0x3f2)
out += struct.pack('>2I', 0x3ea, 1) + bodies[1][:4]
out += struct.pack('>I', 0x3f2)
open(tgt, 'wb').write(out)

# verify
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
