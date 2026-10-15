#!/usr/bin/env python3
"""Reorder RELOC32 groups in xpkDMCU.library to the original's order.

Original hunk0 relocs (14 -> h1, descending-ish):
  7a8 5ec 5d0 59c 3d0 324 254 e2 d2 8c 62 4a 16 6
Original hunk1 relocs: 18 -> h0 then 19 -> h1:
  ->h0: 328 324 320 31c 304 300 2fc 34 30 2c 28 24 20 1c 18 14 10 c
  ->h1: 330 2ca 2a0 276 24c 222 1f8 1ce 1a4 17a fa ea 120 108 f6 f2 e6 8 4
"""
import struct, sys

H0 = {1: [0x7a8, 0x5ec, 0x5d0, 0x59c, 0x3d0, 0x324, 0x254, 0xe2, 0xd2,
          0x8c, 0x62, 0x4a, 0x16, 0x6]}
H1 = {0: [0x328, 0x324, 0x320, 0x31c, 0x304, 0x300, 0x2fc, 0x34, 0x30,
          0x2c, 0x28, 0x24, 0x20, 0x1c, 0x18, 0x14, 0x10, 0xc],
      1: [0x330, 0x2ca, 0x2a0, 0x276, 0x24c, 0x222, 0x1f8, 0x1ce, 0x1a4,
          0x17a, 0xfa, 0xea, 0x120, 0x108, 0xf6, 0xf2, 0xe6, 0x8, 0x4]}

def parse_groups(d, o):
    """Read reloc groups at offset o; return (end, [(hunk,[offs])])."""
    groups = []
    while True:
        n = struct.unpack('>I', d[o:o+4])[0]; o += 4
        if n == 0:
            break
        hn = struct.unpack('>I', d[o:o+4])[0]; o += 4
        offs = [struct.unpack('>I', d[o+4*j:o+4+4*j])[0] for j in range(n)]
        o += 4*n
        groups.append((hn, offs))
    return o, groups

def emit_groups(d, o, groups, want):
    """Rewrite groups in the wanted order (same total size)."""
    for hn, want_offs in want.items():
        pass
    pos = o
    for hn, offs in want.items() if False else []:
        pass
    # emit in 'want' dict order
    for hn, woffs in want.items():
        # find actual group
        for ghn, goffs in groups:
            if ghn == hn:
                assert sorted(goffs) == sorted(woffs), (ghn, goffs)
                break
        else:
            raise AssertionError('missing group h%d' % hn)
        d[pos:pos+4] = struct.pack('>I', len(woffs)); pos += 4
        d[pos:pos+4] = struct.pack('>I', hn); pos += 4
        for w in woffs:
            d[pos:pos+4] = struct.pack('>I', w); pos += 4
    d[pos:pos+4] = struct.pack('>I', 0); pos += 4
    return pos

def main():
    p = sys.argv[1] if len(sys.argv) > 1 else 'xpkDMCU.library'
    d = bytearray(open(p, 'rb').read())
    # hunk0 body ends at file 0x24+0x7d8 = 0x7fc
    end0, g0 = parse_groups(d, 0x7fc + 4)   # after 0x3ec tag
    # hunk1 body: END tag follows groups; h1 body starts after END+tag+size
    o = end0 + 4  # skip HUNK_END
    tag, sz = struct.unpack('>II', d[o:o+8])
    assert tag == 0x3ea, hex(tag)
    body1 = o + 8 + sz*4
    end1, g1 = parse_groups(d, body1 + 4)
    emit_groups(d, 0x7fc + 4, g0, H0)
    emit_groups(d, body1 + 4, g1, H1)
    open(p, 'wb').write(d)

if __name__ == '__main__':
    main()
