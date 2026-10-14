#!/usr/bin/env python3
# Post-link fixup: rewrite hunk0's RELOC32 offset list to the original
# linker's exact (non-sorted) order.
import struct, sys

# original: one group to hunk 0, in this exact order
ORIG = [[
    (0, [0x744,0x740,0x73c,0x738,0x734,0x730,
         0x22,0x2ba,0x46,0x34,0x2a,0x26,0x1a,0x16,0x12,0xa,0x6,
         0x2b4,0x2ac]),
]]

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
