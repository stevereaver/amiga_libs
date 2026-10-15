#!/usr/bin/env python3
# Post-link fixup for geclass.library 37.6:
# rewrite hunk0's RELOC32 records in the original group order
# (16 self-targeting offsets, stored descending; then 7 offsets
# targeting hunk1, stored ascending). h1 is a pure HUNK_BSS (header
# + END, no body) -- the GNU linker may emit it as DATA with a
# zeroed body, so rewrite the tag and drop the body.
import struct, sys

ORIG = [
    # hunk0: (target_hunk, offsets in original order)
    [(0, [0x8a, 0xba, 0xbe, 0xc2, 0xc6, 0xca, 0xce,
          0xb2, 0x98, 0x86, 0x82, 0x1a, 0x16, 0x12, 0xa, 0x6]),
     (1, [0xde, 0xe4, 0x134, 0x1d2, 0x6b2, 0x6d2, 0x74a])],
    [],   # hunk1: BSS, no relocs
]

d = bytearray(open(sys.argv[1], 'rb').read())
nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
o = 0x14 + 4 * nh
out = bytearray(d[:o])
for i in range(nh):
    tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
    sz  = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff; o += 4
    if i == 1:
        # original stores hunk1 as HUNK_BSS: header + END, no body
        if tag != 0x3eb:
            o += sz*4
        body = b''
    else:
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
    out += struct.pack('>II', 0x3eb if i == 1 else tag, sz) + body + recs
    out += struct.pack('>I', 0x3f2)
assert o == len(d), (o, len(d))
open(sys.argv[1], 'wb').write(out)
