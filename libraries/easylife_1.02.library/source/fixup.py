#!/usr/bin/env python3
# Restore original RELOC32 order for easylife.library 1.02.
# One CODE hunk; all relocs point into hunk 0.
import struct, sys

p = sys.argv[1]
d = bytearray(open(p,'rb').read())

# single-hunk header: magic@0, names-term@4, tablesize@8, first@12, last@16, size@20
tsz = struct.unpack('>I', d[8:12])[0]
assert tsz == 1
off = 0x14 + 4*tsz
htag, hsz = struct.unpack('>II', d[off:off+8])
assert htag == 0x3e9, hex(htag)
body = off + 8
eob = body + hsz*4
# find RELOC32
o = eob
tag = struct.unpack('>I', d[o:o+4])[0]
assert tag == 0x3ec, hex(tag)
o += 4
groups = []
while True:
    n = struct.unpack('>I', d[o:o+4])[0]; o += 4
    if n == 0: break
    tgt = struct.unpack('>I', d[o:o+4])[0]; o += 4
    offs = [struct.unpack('>I', d[o+4*j:o+4+4*j])[0] for j in range(n)]
    o += 4*n
    groups.append((tgt, offs))
ORIG = [0x6,0xa,0x12,0x16,0x1a,0x68,0x6c,0x70,0x74,0x78,0x7c,0x80,0x84,0x88,
        0x8c,0x90,0x94,0x98,0x9c,0xa0,0xa4,0xa8,0xac,0xb0,0xb4,0xb8,0xc6,0xd8]
flat = sorted(x for g in groups for x in g[1])
assert flat == sorted(ORIG), ('reloc set mismatch', flat)
# rewrite as one group -> hunk 0 in ORIG order
rel = struct.pack('>I', len(ORIG)) + struct.pack('>I', 0)
rel += b''.join(struct.pack('>I', x) for x in ORIG) + struct.pack('>I',0)
end = struct.pack('>I',0x3f2)
d2 = d[:eob] + struct.pack('>I',0x3ec) + rel + end
open(p,'wb').write(d2)
print('fixup ok, size', len(d2))
