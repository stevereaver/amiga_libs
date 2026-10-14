#!/usr/bin/env python3
# Post-link fixup: rewrite the RELOC32 offset lists of each hunk to the
# original linker's order (as read from binary/ppipc_2.2.library).
import struct, sys

# original order per hunk: list of (target_hunk, offsets)
ORIG = [
    # hunk0
    [(0, [0xa, 0x6]),
     (2, [0x1a, 0x16, 0x12])],
    # hunk1
    [(2, [0x2a, 0x10])],
    # hunk2
    [(1, [0x92]),
     (2, [0x8e]),
     (3, [0x96, 0x82, 0x7e, 0x7a, 0x76, 0x3a, 0x36, 0x32, 0x2e]),
     (5, [0x66, 0x62, 0x5e, 0x5a, 0x56, 0x52, 0x4e, 0x4a, 0x46, 0x42, 0x3e]),
     (7, [0x6a]),
     (9, [0x72, 0x6e])],
    # hunk3
    [(0, [0xe2]),
     (1, [0xe]),
     (2, [0x24, 0x1c]),
     (4, [0xb0, 0x14]),
     (6, [0x76, 0x2c])],
    # hunk4
    [],
    # hunk5
    [(0, [0x3ba, 0x3b4, 0x3ae]),
     (6, [0x130, 0xda, 0x7a])],
    # hunk6 (BSS)
    [],
    # hunk7
    [(5, [0x118, 0x100, 0x112, 0x130, 0x11e, 0x12a, 0xfa, 0x124]),
     (8, [0x66]),
     (10, [0x10c, 0x106])],
    # hunk8
    [],
    # hunk9
    [],
    # hunk10
    [(1, [0x18, 0x4])],
]

d = bytearray(open(sys.argv[1], 'rb').read())
nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
o = 0x14 + 4 * nh
for i in range(nh):
    tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
    sz  = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff; o += 4
    if tag != 0x3eb:
        o += sz * 4                              # body
    groups = ORIG[i]
    while True:
        t = struct.unpack('>I', d[o:o+4])[0]; o += 4
        if t == 0x3ec:                           # RELOC32
            # flatten existing (target,offset) pairs
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
            # rewrite in original order
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
