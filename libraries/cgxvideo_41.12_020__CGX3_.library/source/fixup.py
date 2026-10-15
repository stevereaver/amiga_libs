#!/usr/bin/env python3
# fixup.py -- cgxvideo.library 41.12 (020) rebuild fixup.
# GNU ld merges the three .text inputs (cgx_h0/cgx_h2/cgx_h3) into one
# CODE hunk and emits no HUNK_SYMBOL tail.  Pool the linked bodies per
# type in order, verify each original hunk body byte for byte, then
# re-emit the file as: original header + (tag,size) + verified body +
# original tail (RELOC32 groups, HUNK_SYMBOL records, HUNK_END).
import struct, sys

ORIG = "../binary/cgxvideo_41.12(020)(CGX3).library"

def hunks(d):
    nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
    o = 0x14 + 4 * nh
    out = []
    for _ in range(nh):
        t = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff
        s = struct.unpack('>I', d[o+4:o+8])[0] & 0x3fffffff
        o += 8
        body = d[o:o+s*4]
        o += 0 if t == 0x3eb else s*4
        ts = o
        while o + 4 <= len(d):
            tt = struct.unpack('>I', d[o:o+4])[0]; o += 4
            if tt == 0x3f2:
                break
            if tt == 0x3ec:
                while True:
                    c = struct.unpack('>I', d[o:o+4])[0]; o += 4
                    if c == 0:
                        break
                    o += 4 + c * 4
            elif tt == 0x3f7:
                while True:
                    c = struct.unpack('>H', d[o:o+2])[0]; o += 2
                    if c == 0:
                        o += 2
                        o += (-o) & 3
                        break
                    o += 2 + c * 2
            elif tt == 0x3f0:
                while True:
                    nl = struct.unpack('>I', d[o:o+4])[0]; o += 4
                    if nl == 0:
                        break
                    o += nl * 4 + 4
            elif tt in (0x3f1, 0x3e8):
                o += 4 * struct.unpack('>I', d[o:o+4])[0] + 4
            else:
                break
        out.append((t, body, d[ts:o]))
    return out, 0x14 + 4 * nh

od = open(ORIG, 'rb').read()
nd = open(sys.argv[1], 'rb').read()
oh, ohdr = hunks(od)
mh, _ = hunks(nd)

# pool linked bodies per type in hunk order
pool = {}
for t, body, _ in mh:
    pool[t] = pool.get(t, b'') + body

cur = {k: 0 for k in pool}
out = bytearray(od[:ohdr])
for i, (t, body, tail) in enumerate(oh):
    if t == 0x3eb:
        seg = b''
    else:
        seg = pool[t][cur[t]:cur[t] + len(body)]
        assert seg == body, 'hunk %d body mismatch' % i
        cur[t] += len(body)
    out += struct.pack('>II', t, len(body) // 4) + seg + tail
for t, n in cur.items():
    assert n == len(pool[t]), 'pool %x leftover %d' % (t, len(pool[t]) - n)
open(sys.argv[1], 'wb').write(bytes(out))
print('fixup ok, wrote %d' % len(out))
