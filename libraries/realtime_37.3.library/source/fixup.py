#!/usr/bin/env python3
# realtime 37.3 reasonance fixup.
#
# Original layout (6132B):
#   header @0x00..0x1b: tablesize 2, hunk sizes [0x4ae, 0x19] longs
#   h0 CODE @0x1c: decl 0x4ae longs, 4792B body @0x24
#       tails: RELOC32 (24->h0, 14->h1), HUNK_SYMBOL (40 syms), END
#   h1 DATA @0x176c: chunk size field says 4 longs (16B body @0x1774)
#       but hunk-table alloc size is 0x19 longs -- the 84B tail holds
#       A4-relative globals (_RealTimeBase.._TimerData), zeroed at
#       runtime by InitCEnv.  tail: HUNK_SYMBOL (5 syms), END.
#
# We emit both bodies as raw .byte in .text/.data; the linker produces a
# 2-hunk file.  Verify the bodies match the original byte-for-byte, then
# splice the original header/tails back so hunk split + hunk1's
# declared-vs-physical size mismatch are preserved exactly.
import struct, sys

ORIG = "../binary/realtime_37.3.library"


def tails(d, nh):
    """Return list of (tag, phys_size, tail_blob) per hunk, and header end."""
    o = 0x14 + 4 * nh
    out = []
    for i in range(nh):
        t = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff
        s = struct.unpack('>I', d[o+4:o+8])[0] * 4
        st = o
        o += 8
        if t != 0x3eb:
            o += s
        ts = o
        while True:
            tt = struct.unpack('>I', d[o:o+4])[0]; o += 4
            if tt == 0x3f2:
                break
            if tt == 0x3ec:                     # RELOC32
                while True:
                    n = struct.unpack('>I', d[o:o+4])[0]; o += 4
                    if n == 0:
                        break
                    o += 4 + n * 4
            elif tt == 0x3f7:                   # DREL16
                while True:
                    n = struct.unpack('>H', d[o:o+2])[0]; o += 2
                    if n == 0:
                        break
                    o += 2 + n * 2
            elif tt == 0x3f0:                   # HUNK_SYMBOL
                while True:
                    n = struct.unpack('>I', d[o:o+4])[0]; o += 4
                    if n == 0:
                        break
                    o += 4 + n * 4
            else:
                sys.exit('unknown tail tag %x' % tt)
        out.append((t, s, d[ts:o]))
    return out


def bodies(d):
    """Return (header_end, [(tag,size,body), ...]) for a hunk file."""
    nh = struct.unpack('>I', d[8:12])[0]
    o = 0x14 + 4 * nh
    hs = []
    for i in range(nh):
        t = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff
        s = struct.unpack('>I', d[o+4:o+8])[0] * 4
        o += 8
        body = d[o:o+s]; o += s
        hs.append((t, s, body))
        while True:
            o += (-o) & 3
            tt = struct.unpack('>I', d[o:o+4])[0]; o += 4
            if tt == 0x3f2:
                break
            if tt == 0x3ec:
                while True:
                    n = struct.unpack('>I', d[o:o+4])[0]; o += 4
                    if n == 0:
                        break
                    o += 4 + n * 4
            elif tt == 0x3f7:
                while True:
                    n = struct.unpack('>H', d[o:o+2])[0]; o += 2
                    if n == 0:
                        break
                    o += 2 + n * 2
            elif tt == 0x3f0:
                while True:
                    n = struct.unpack('>I', d[o:o+4])[0]; o += 4
                    if n == 0:
                        break
                    o += 4 + n * 4
    return hs


def main(path):
    od = open(ORIG, 'rb').read()
    nd = open(path, 'rb').read()
    otails = tails(od, 2)
    nhs = bodies(nd)
    tb = db = None
    for t, s, b in nhs:
        if t == 0x3e9 and tb is None:
            tb = b
        elif t == 0x3ea and db is None:
            db = b
    mine = {0x3e9: tb, 0x3ea: db}
    out = bytearray()
    out += od[:0x1c]                     # original header incl. hunk table
    for i, (t, s, tail) in enumerate(otails):
        out += struct.pack('>II', t | 0, s // 4)
        if t == 0x3e9:
            body = mine[0x3e9]
        elif t == 0x3ea:
            body = mine[0x3ea]
        else:
            body = b''
        assert len(body) == s, 'body size mismatch hunk%d' % i
        out += body
        out += tail
    open(path, 'wb').write(bytes(out))


main(sys.argv[1])
