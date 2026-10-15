#!/usr/bin/env python3
# Post-link fixup: declare the second (empty) CODE hunk in the header,
# rewrite hunk0's RELOC32 in the original (descending) order, append
# the empty hunk1 record.
import struct, sys

ORIG = [(0, [0x90, 0x76, 0x64, 0x60, 0x5c, 0x58, 0x54, 0x50, 0x4c, 0x1a, 0x16, 0x12, 0xa, 0x6])]

d = bytearray(open(sys.argv[1], 'rb').read())
assert struct.unpack('>I', d[0:4])[0] == 0x3f3
nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
assert nh == 1, 'expected single-hunk ld output'

o = 0x14 + 4 * nh
tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
assert tag == 0x3e9
sz = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff; o += 4
assert sz == 0x43, hex(sz)
body = d[o:o + sz * 4]; o += sz * 4

t = struct.unpack('>I', d[o:o+4])[0]; o += 4
assert t == 0x3ec
got = []
while True:
    n = struct.unpack('>I', d[o:o+4])[0]; o += 4
    if n == 0: break
    hn = struct.unpack('>I', d[o:o+4])[0]; o += 4
    got += [(hn, struct.unpack('>I', d[o+4*j:o+4+4*j])[0])
            for j in range(n)]
    o += 4 * n
assert sorted(got) == sorted(
    (h, x) for h, l in ORIG for x in l), got

out = bytearray()
out += struct.pack('>7I', 0x3f3, 0, 2, 0, 1, 0x43, 0)
out += struct.pack('>2I', 0x3e9, 0x43) + body
out += struct.pack('>I', 0x3ec)
for hn, offs in ORIG:
    out += struct.pack('>2I', len(offs), hn)
    for x in offs:
        out += struct.pack('>I', x)
out += struct.pack('>I', 0)
out += struct.pack('>I', 0x3f2)
out += struct.pack('>3I', 0x3e9, 0, 0x3f2)
open(sys.argv[1], 'wb').write(out)
