#!/usr/bin/env python3
# Post-link fixup: rewrite the RELOC32 offset lists of each hunk to the
# original linker's (descending, grouped-by-target) order.
import struct, sys

ORIG = [
    # hunk0
    [(0, [0x884, 0x880, 0x87c, 0x878, 0x874, 0x870, 0x86c, 0x868,
          0x5a, 0x34, 0x16, 0x12, 0xa, 0x6]),
     (1, [0x86, 0x74, 0x1a])],
    # hunk1
    [(0, [0x50, 0x4c, 0x48, 0x44, 0x40, 0x3c, 0x38, 0x34, 0x30,
          0x2c, 0x28, 0x24, 0x20, 0x1c, 0x8, 0x10])],
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
