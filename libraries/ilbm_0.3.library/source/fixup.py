#!/usr/bin/env python3
# verify the linked concat-body against orig's content hunks, then
# emit the original hunk structure verbatim (header, tails, reloc).
import struct, sys
ORIG = sys.argv[2]
def hunks(d):
    n = struct.unpack(">I", d[8:12])[0]
    o = 0x14 + 4*n
    out = []
    while o + 8 <= len(d):
        tag, sz = struct.unpack(">II", d[o:o+8]); sz &= 0x3fffffff
        b = o + 8; e = b + (0 if tag == 0x3eb else sz*4)
        j = e
        known = (0x3e9,0x3ea,0x3eb,0x3ec,0x3ed,0x3ee,0x3ef,
                 0x3f0,0x3f1,0x3f2,0x3f8,0x3fd)
        while True:
            if j + 4 > len(d): j = len(d); break
            t = struct.unpack(">I", d[j:j+4])[0]
            if t == 0x3f2: j += 4; break
            if t == 0x3ec:
                j += 4
                while True:
                    c = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if c == 0: break
                    j += 4 + c*4
                continue
            if t == 0x3f0:
                j += 4
                while True:
                    nl = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if nl == 0: break
                    j += nl*4 + 4
                continue
            if t in (0x3e8,0x3f1,0x3f4,0x3f6):
                j += 4 + struct.unpack(">I", d[j:j+4])[0]*4
                continue
            if t in (0x3e9,0x3ea,0x3eb):
                break
            j += 4
            while j + 4 <= len(d) and struct.unpack(">I", d[j:j+4])[0] not in known:
                j += 4
            continue
        out.append((tag, b, e, d[e:j], sz))
        o = j
    return out
orig = open(ORIG,"rb").read(); mine = open(sys.argv[1],"rb").read()
oh, mh = hunks(orig), hunks(mine)
obody = b"".join(orig[b:e] for t,b,e,_,s in oh if t in (0x3e9,0x3ea))
mbody = b"".join(mine[b:e] for t,b,e,_,s in mh if t in (0x3e9,0x3ea))
assert obody == mbody, "body mismatch (%d vs %d)" % (len(obody), len(mbody))
hdr = 0x14 + 4*struct.unpack(">I",orig[8:12])[0]
out = bytearray(orig[:hdr])
for (ot,ob,oe,otail,osz) in oh:
    out += struct.pack(">II", ot, osz) + orig[ob:oe] + otail
open(sys.argv[1],"wb").write(out)
