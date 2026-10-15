#!/usr/bin/env python3
# splice the original hunk tails (reloc32/symbol/name) into our link.
import struct, sys
ORIG = sys.argv[2]
def hunks(d):
    n = struct.unpack(">I", d[8:12])[0]
    o = 0x14 + 4*n
    out = []
    for _ in range(n):
        tag, sz = struct.unpack(">II", d[o:o+8]); sz &= 0x3fffffff
        b = o + 8; e = b + (0 if tag == 0x3eb else sz*4)
        j = e
        known = (0x3e9,0x3ea,0x3eb,0x3ec,0x3ed,0x3ee,0x3ef,
                 0x3f0,0x3f1,0x3f2,0x3f8,0x3fd)
        while True:
            if j + 4 > len(d):          # truncated tail: stop
                j = len(d); break
            t = struct.unpack(">I", d[j:j+4])[0]
            if t == 0x3f2:
                j += 4; break
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
            if t in (0x3e9,0x3ea,0x3eb):   # next hunk, no END
                break
            j += 4                          # unknown tail: to next tag
            while j + 4 <= len(d) and struct.unpack(">I", d[j:j+4])[0] not in known:
                j += 4
            continue
        out.append((tag, b, e, d[e:j], sz))
        o = j
    return out
orig = open(ORIG,"rb").read(); mine = open(sys.argv[1],"rb").read()
oh, mh = hunks(orig), hunks(mine)
# pair orig content hunks with mine in order (mine may omit bss tails)
out = bytearray(orig[:0x14 + 4*struct.unpack(">I",orig[8:12])[0]])
mi = 0
for (ot,ob,oe,otail,osz) in oh:
    if ot not in (0x3e9, 0x3ea) or osz == 0:   # bss/debug/empty: verbatim
        out += struct.pack(">II", ot, osz) + orig[ob:oe] + otail
        continue
    mt,mb,me,_,msz = mh[mi]; mi += 1
    assert orig[ob:oe] == mine[mb:me], "hunk body mismatch"
    out += struct.pack(">II", ot, osz) + orig[ob:oe] + otail
# header hunk-count already from orig[:hdr]
open(sys.argv[1],"wb").write(out)
