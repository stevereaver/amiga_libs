#!/usr/bin/env python3
# Post-link fixup for fortunates.library 1.4:
# rewrite hunk0's RELOC32 records in the original group order
# (targets h0, then h1, then h2 -- the GNU linker interleaves them
# differently). h1 has no relocs; h2 is emitted as HUNK_BSS already.
import struct, sys

ORIG = [
    # hunk0: (target_hunk, offsets in original order)
    [(0, [0x6, 0xa, 0x12, 0x16, 0x1a,
          0xde, 0xe2, 0xe6,
          0xea, 0xee, 0xf2, 0xf6, 0xfa, 0xfe, 0x102, 0x106, 0x10a,
          0x10e, 0x112, 0x116, 0x11a, 0x11e, 0x122, 0x126, 0x12a,
          0x138, 0x14a,
          0x4e4, 0x60c, 0x654, 0x688, 0x7be]),
     (1, [0x518, 0x5e6]),
     (2, [0x16e, 0x176, 0x186, 0x196, 0x1a6, 0x1b6, 0x1c6, 0x1d6,
          0x1e6, 0x1f6, 0x26a, 0x274, 0x27e, 0x288, 0x292, 0x29c,
          0x2a6, 0x2b0, 0x2de, 0x2f0, 0x30a, 0x318, 0x338, 0x360,
          0x39e, 0x3ee, 0x40e, 0x438, 0x444, 0x476, 0x4f6, 0x506,
          0x512, 0x520, 0x52e, 0x54e, 0x570, 0x59e, 0x5ae, 0x5c4,
          0x5d4, 0x5e0, 0x5ee, 0x5fc, 0x616, 0x622, 0x66c, 0x8d6,
          0x986, 0x9b0, 0x9bc, 0x9c8])],
    [],   # hunk1: no relocs
    [],   # hunk2: BSS, no relocs
]

d = bytearray(open(sys.argv[1], 'rb').read())
nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
o = 0x14 + 4 * nh
out = bytearray(d[:o])
for i in range(nh):
    tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
    sz  = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff; o += 4
    if i == 2:
        # original stores hunk2 as HUNK_BSS: header + END, no body
        o += sz*4 if tag == 0x3ea else 0
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
            # same-section absolute refs (jsr h0 subs) emit no reloc;
            # linker output must be a subset of the original set.
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
    out += struct.pack('>II', 0x3eb if i == 2 else tag, sz) + body + recs
    out += struct.pack('>I', 0x3f2)
assert o == len(d), (o, len(d))
open(sys.argv[1], 'wb').write(out)
