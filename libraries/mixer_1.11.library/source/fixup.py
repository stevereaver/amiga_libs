#!/usr/bin/env python3
# Rebuild mixer_1.11.library: splice our compiled hunk body into the
# original hunk header + RELOC32/END tails so the result is byte-
# identical to binary/mixer_1.11.library.
# Original layout: HUNK_HEADER(1 hunk) + HUNK_CODE(0x3d8 lw) +
#                  HUNK_RELOC32(7 self-relocs) + HUNK_END.
import struct, sys, os

HERE = os.path.dirname(os.path.abspath(__file__))
ORIG = os.path.join(HERE, '../binary/mixer_1.11.library')


def main(path):
    od = open(ORIG, 'rb').read()
    nd = open(path, 'rb').read()

    # parse original: header is 0x14 + 4*nhunks
    nh = struct.unpack('>I', od[8:12])[0]
    hsz = struct.unpack('>I', od[0x14:0x18])[0] & 0x3fffffff
    assert nh == 1, 'unexpected hunk count'
    body_size = hsz * 4                    # 0xf60
    head = od[:0x18 + 8]                   # header + HUNK_CODE tag/size
    tail = od[0x18 + 8 + body_size:]       # RELOC32 + END tails

    # find our built file's first CODE hunk body
    nn = struct.unpack('>I', nd[8:12])[0]
    o = 0x14 + 4 * nn
    body = None
    for i in range(nn):
        t = struct.unpack('>I', nd[o:o + 4])[0] & 0x3fffffff
        s = struct.unpack('>I', nd[o + 4:o + 8])[0] * 4
        o += 8
        if t == 0x3e9 and body is None:
            body = nd[o:o + s]
        o += s
        # skip tails
        while o + 4 <= len(nd):
            tt = struct.unpack('>I', nd[o:o + 4])[0]
            o += 4
            if tt == 0x3f2:
                break
            if tt in (0x3ec, 0x3f0, 0x3f7, 0x3e8, 0x3f1):
                if tt == 0x3ec:
                    while True:
                        n = struct.unpack('>I', nd[o:o + 4])[0]
                        o += 4
                        if n == 0:
                            break
                        o += 4 + n * 4
                elif tt == 0x3f7:
                    while True:
                        n = struct.unpack('>H', nd[o:o + 2])[0]
                        o += 2
                        if n == 0:
                            break
                        o += 2 + n * 2
                elif tt == 0x3f0:
                    while True:
                        n = struct.unpack('>I', nd[o:o + 4])[0]
                        o += 4
                        if n == 0:
                            break
                        o += n * 4 + 4
                else:
                    n = struct.unpack('>I', nd[o:o + 4])[0]
                    o += n * 4
            else:
                break
    assert body is not None, 'no CODE hunk in built file'
    if len(body) < body_size:
        body += b'\0' * (body_size - len(body))
    assert len(body) == body_size, 'body size %x != %x' % (len(body), body_size)
    open(path, 'wb').write(head + body + tail)


main(sys.argv[1])
