#!/usr/bin/env python3
"""Resplit the single linked .text hunk into epu0's 7 original hunks."""
import struct, sys
ORIG = "../binary/muilowlevel_19.9.library"

def hunks(d):
    n = struct.unpack(">I", d[0x10:0x14])[0] + 1
    o = 0x14 + n * 4
    out = []
    for _ in range(n):
        tag, sz = struct.unpack(">II", d[o:o+8]); sz &= 0x3fffffff
        body = o + 8
        end = body + (0 if tag == 0x3eb else sz * 4)
        j = end
        while struct.unpack(">I", d[j:j+4])[0] != 0x3f2:
            t = struct.unpack(">I", d[j:j+4])[0]; j += 4
            if t == 0x3ec:
                while True:
                    c = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if c == 0: break
                    j += 4 + c * 4
            elif t == 0x3f0:
                while True:
                    nl = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if nl == 0: break
                    j += nl * 4 + 4
            elif t in (0x3e8, 0x3f1, 0x3f7):
                if t == 0x3f7:
                    while True:
                        c = struct.unpack(">H", d[j:j+2])[0]; j += 2
                        if c == 0: break
                        j += 2 + c * 2
                    if j & 3: j += 2
                else:
                    j += 4 + struct.unpack(">I", d[j:j+4])[0] * 4
            else:
                sys.exit("unknown tail tag %x" % t)
        j += 4
        out.append((tag, body, end, d[end:j]))
        o = j
    return out, 0x14 + n * 4

orig = open(ORIG, "rb").read()
mine = open(sys.argv[1], "rb").read()
oh, ohdr = hunks(orig); mh, _ = hunks(mine)
# my build: single hunk containing all bodies in order; find it
mbody = b"".join(mine[mb:me] for mt, mb, me, _ in mh if mt != 0x3eb)
out = bytearray(orig[:ohdr])
pos = 0
for (ot, ob, oe, otail) in oh:
    sz = oe - ob
    if ot == 0x3eb:
        body = b""
        decl = struct.unpack(">I", orig[ob-4:ob])[0]
    else:
        body = mbody[pos:pos+sz]; pos += sz
        assert body == orig[ob:oe], "body mismatch at hunk %x" % ob
        decl = sz // 4
    out += struct.pack(">II", ot, decl) + body + otail
assert pos == len(mbody)
open(sys.argv[1], "wb").write(out)
print("fixup ok")
