#!/usr/bin/env python3
# Post-link fixup: rewrite the RELOC32 offset list of hunk 0 to the
# original linker's order: 0xa,0x6,0x12,0x16,0x1a,0x4c,0x50,0x54
# (EndSkip reloc precedes MatchTag in the original).
import struct, sys

ORIG = [
    # hunk0
    [(0, [0xa, 0x6, 0x12, 0x16, 0x1a, 0x4c, 0x50, 0x54])],
]

d = bytearray(open(sys.argv[1], 'rb').read())
nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
o = 0x14 + 4 * nh
for i in range(nh):
    tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
    sz  = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff; o += 4
    o += sz * 4                                  # body
    groups = ORIG[i]
    while True:
        t = struct.unpack('>I', d[o:o+4])[0]; o += 4
        if t == 0x3ec:                           # RELOC32
            got = []
            p0 = o
            while True:
                n = struct.unpack('>I', d[o:o+4])[0]; o += 4
                if n == 0: break
                hn = struct.unpack('>I', d[o:o+4])[0]; o += 4
                got += [(hn, struct.unpack('>I', d[o+4*j:o+4+4*j])[0])
                        for j in range(n)]
                o += 4 * n
            assert sorted(got) == sorted(
                (h, x) for h, l in groups for x in l), (i, got)
            o = p0
            for hn, offs in groups:
                struct.pack_into('>I', d, o, len(offs)); o += 4
                struct.pack_into('>I', d, o, hn); o += 4
                for x in offs:
                    struct.pack_into('>I', d, o, x); o += 4
            struct.pack_into('>I', d, o, 0); o += 4
        elif t == 0x3f2:
            break
        else:
            raise Exception('tag %x at %x' % (t, o-4))
open(sys.argv[1], 'wb').write(d)
