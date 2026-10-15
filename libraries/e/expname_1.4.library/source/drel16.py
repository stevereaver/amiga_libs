#!/usr/bin/env python3
# Post-link fixup: rewrite the RELOC32 (0x3ec) hunk tail as DREL16
# (0x3f7) word-offset relocations, matching the original binary's
# toolchain output.  All offsets are < 0x10000 so they fit in words.
# The original lists the offsets in reverse order and terminates the
# hunk with a single 0x0000 word.
import struct, sys

d = bytearray(open(sys.argv[1], 'rb').read())
n = struct.unpack('>I', d[16:20])[0]
pos = 24 + 4 * n
out = bytearray(d[:pos])
while pos < len(d):
    t = struct.unpack('>I', d[pos:pos + 4])[0]
    pos += 4
    ty = t & 0x3fffffff
    if ty == 0x3e9:  # CODE
        sz = struct.unpack('>I', d[pos:pos + 4])[0]
        out += d[pos - 4:pos + 4 + sz * 4]
        pos += 4 + sz * 4
    elif ty == 0x3ec:  # RELOC32 -> DREL16
        offs = []
        while True:
            cnt = struct.unpack('>I', d[pos:pos + 4])[0]
            pos += 4
            if cnt == 0:
                break
            tgt = struct.unpack('>I', d[pos:pos + 4])[0]
            pos += 4
            o = struct.unpack('>' + str(cnt) + 'I', d[pos:pos + cnt * 4])
            pos += cnt * 4
            assert all(x < 0x10000 for x in o)
            out += struct.pack('>IHH', 0x3f7, cnt, tgt)
            o = sorted(o, reverse=True)
            # original linker's tail quirk: RomTag MatchWord (6) is
            # emitted before EndSkip (10) despite the smaller offset
            if o[-2:] == [10, 6]:
                o[-2:] = [6, 10]
            out += struct.pack('>' + str(cnt) + 'H', *o)
        out += struct.pack('>HH', 0, 0)  # DREL16 term word + pad to END
    elif ty == 0x3f2:  # END
        out += struct.pack('>I', 0x3f2)
        break
    else:
        raise SystemExit('unhandled hunk %#x @ %#x' % (ty, pos - 4))
open(sys.argv[1], 'wb').write(out)
