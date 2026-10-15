#!/usr/bin/env python3
# Post-link fixup for config.library 1.0:
#  * rewrite both hunks' RELOC32 records in the original group order:
#    h0: one group -> hunk1 (scrambled, not ascending)
#    h1: group -> hunk0 (InitRoutine+functab), then group -> hunk1
#  * restore hunk-table size quirk: table entry for hunk1 = 0x56 longs
#    while the DATA hunk's own size field stays 0x55.
import struct, sys

H0_TO_H1 = [0x486, 0x2e8, 0x2aa, 0x8, 0x6b2, 0x62c,
            0x7de, 0x77e, 0x754, 0x73c, 0x706, 0x6f0]
H1_TO_H0 = [0x124, 0x128, 0x12c, 0x130, 0x134, 0x138, 0x13c, 0x140, 0x144]
H1_TO_H1 = [0xa6, 0xc6, 0xb2, 0xde, 0xb6, 0xaa, 0xba, 0x11c, 0x120]

ORIG = [
    [(1, H0_TO_H1)],
    [(0, H1_TO_H0), (1, H1_TO_H1)],
]

d = bytearray(open(sys.argv[1], 'rb').read())
nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
o = 0x14 + 4 * nh
out = bytearray(d[:o])
for i in range(nh):
    tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
    sz  = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff; o += 4
    body = d[o:o+sz*4]; o += sz*4
    recs = bytearray()
    while True:
        t = struct.unpack('>I', d[o:o+4])[0]; o += 4
        if t == 0x3ec:
            got = []
            while True:
                n = struct.unpack('>I', d[o:o+4])[0]; o += 4
                if n == 0: break
                hn = struct.unpack('>I', d[o:o+4])[0]; o += 4
                got += [(hn, struct.unpack('>I', d[o+4*j:o+4+4*j])[0])
                        for j in range(n)]
                o += 4 * n
            want = {(h, x) for h, l in ORIG[i] for x in l}
            assert set(got) <= want, (i, sorted(set(got) - want))
            assert set(got) == want, (i, sorted(want - set(got)))
            recs += struct.pack('>I', 0x3ec)
            for hn, offs in ORIG[i]:
                recs += struct.pack('>II', len(offs), hn)
                for x in offs:
                    recs += struct.pack('>I', x)
            recs += struct.pack('>I', 0)
        elif t == 0x3f2:
            break
        else:
            raise Exception('tag %x at %x' % (t, o-4))
    out += struct.pack('>II', tag, sz) + body + recs
    out += struct.pack('>I', 0x3f2)
assert o == len(d), (o, len(d))
# hunk-table size quirk: table[1] must read 0x56, not the body's 0x55
struct.pack_into('>I', out, 0x18, 0x56)
open(sys.argv[1], 'wb').write(bytes(out))
