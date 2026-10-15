#!/usr/bin/env python3
# Rewrite GNU ld's RELOC32 groups with the original producer's exact
# offset ordering (quirky: hunk1 groups run descending, hunk0's ->hunk1
# group is in hash order, not sorted) and verify byte-exactness.
import struct, sys

tgt = sys.argv[1] if len(sys.argv) > 1 else 'iconobject.library'
orig = sys.argv[2] if len(sys.argv) > 2 else '../binary/iconobject_40.5.library'

# original relocation record order (from binary analysis)
R0 = [(0, [0x862]),
      (1, [0x6ee,0x7e0,0x788,0x760,0x732,0x6e8,0x6d4,0x640,0x624,
           0x5c6,0x59e,0x50e,0x4ec,0x480,0x66c,0x520,0x388,0x368,
           0x18e,0x17e,0x16a,0x56,0x44,0x32,0x20,0x6a6,0x5fa,0x56e,
           0x53c,0x4f2,0x4bc,0x41a,0x40c,0x3f6,0x3e8,0x3cc,0x376,
           0x33e,0x332,0x326,0x2ea,0x2aa,0x292,0x27c,0x126,0x114,
           0x10e,0xfc,0xf6,0xe4,0xde,0xcc,0x78,0x70,0x68,0x62,0x50,
           0x3e,0x2c])]
R1 = [(0, [0x128,0x124,0x120,0x11c,0x118,0x114,0x110,0x13c,0x10c,
           0x108,0x104,0x100]),
      (1, [0x152,0x14e,0x156,0x146,0x142,0x134])]

d = open(tgt, 'rb').read()
assert d[:4] == b'\x00\x00\x03\xf3'
o = 0x1c
bodies, rels = [], {}
while o < len(d):
    tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
    if tag in (0x3e9, 0x3ea):
        n = struct.unpack('>I', d[o:o+4])[0] * 4; o += 4
        bodies.append(bytearray(d[o:o+n])); o += n
    elif tag == 0x3ec:
        while True:
            c = struct.unpack('>I', d[o:o+4])[0]; o += 4
            if c == 0:
                break
            t = struct.unpack('>I', d[o:o+4])[0]; o += 4
            rels.setdefault(t, [])
            rels[t] += list(struct.unpack('>%dI' % c, d[o:o+4*c]))
            o += 4*c
    elif tag == 0x3f2:
        pass
    else:
        break

# sanity: relocated fields must be exactly the original sets
assert len(bodies) == 2 and len(bodies[0]) == 0x8fc \
    and len(bodies[1]) == 0x170
# re-walk keeping association hunk -> {target: offsets}
got = {}
o = 0x1c
hi = -1
while o < len(d):
    tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
    if tag in (0x3e9, 0x3ea):
        n = struct.unpack('>I', d[o:o+4])[0] * 4; o += 4
        o += n; hi += 1
    elif tag == 0x3ec:
        while True:
            c = struct.unpack('>I', d[o:o+4])[0]; o += 4
            if c == 0:
                break
            t = struct.unpack('>I', d[o:o+4])[0]; o += 4
            got.setdefault(hi, {}).setdefault(t, [])
            got[hi][t] += list(struct.unpack('>%dI' % c, d[o:o+4*c]))
            o += 4*c
    elif tag == 0x3f2:
        pass
    else:
        break

def relout(groups):
    b = struct.pack('>I', 0x3ec)
    for t, offs in groups:
        b += struct.pack('>2I', len(offs), t)
        b += struct.pack('>%dI' % len(offs), *offs)
    b += struct.pack('>I', 0)
    return b

for hi, want in ((0, R0), (1, R1)):
    for t, offs in want:
        assert sorted(got.get(hi, {}).get(t, [])) == sorted(offs), \
            (hi, t, got.get(hi, {}).get(t), offs)

out = bytearray()
out += struct.pack('>7I', 0x3f3, 0, 2, 0, 1, 0x23f, 0x5c)
out += struct.pack('>2I', 0x3e9, 0x23f) + bodies[0]
out += relout(R0) + struct.pack('>I', 0x3f2)
out += struct.pack('>2I', 0x3ea, 0x5c) + bodies[1]
out += relout(R1) + struct.pack('>I', 0x3f2)
open(tgt, 'wb').write(out)

o = open(orig, 'rb').read()
if o == bytes(out):
    print('BYTE-IDENTICAL', tgt)
else:
    print('size %d vs %d' % (len(out), len(o)))
    for i in range(min(len(o), len(out))):
        if o[i] != out[i]:
            print('first diff @%x: %02x vs %02x' % (i, o[i], out[i]))
            break
    sys.exit(1)
