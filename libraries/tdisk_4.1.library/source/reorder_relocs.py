#!/usr/bin/env python3
# Post-link fixup: the original toolchain emitted each RELOC32 offset
# group in descending order; GNU ld emits ascending.  Reverse each
# group so the file is byte-identical.
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
    elif ty == 0x3ec:  # RELOC32
        out += struct.pack('>I', t)
        while True:
            cnt = struct.unpack('>I', d[pos:pos + 4])[0]
            pos += 4
            if cnt == 0:
                out += struct.pack('>I', 0)
                break
            tgt = struct.unpack('>I', d[pos:pos + 4])[0]
            pos += 4
            o = struct.unpack('>' + str(cnt) + 'I', d[pos:pos + cnt * 4])
            pos += cnt * 4
            out += struct.pack('>II', cnt, tgt)
            out += struct.pack('>' + str(cnt) + 'I', *reversed(o))
    elif ty == 0x3f2:  # END
        out += struct.pack('>I', 0x3f2)
        break
    else:
        raise SystemExit('unhandled hunk %#x @ %#x' % (ty, pos - 4))
open(sys.argv[1], 'wb').write(out)
