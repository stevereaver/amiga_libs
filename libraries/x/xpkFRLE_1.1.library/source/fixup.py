#!/usr/bin/env python3
# fixup.py -- post-link fixup for xpkFRLE.library 1.1.
#
# The shipped binary's HUNK_RELOC32 offset table is stored in
# DESCENDING order (the original toolchain walked its reloc list
# back-to-front).  GNU ld emits the same set in ascending order, so we
# rewrite the table entries in place: sorted set, reversed.
import struct, sys

def main(path):
    d = bytearray(open(path, 'rb').read())
    nh = struct.unpack('>I', d[0x10:0x14])[0] + 1
    o = 0x14 + 4 * nh
    while True:
        tag = struct.unpack('>I', d[o:o+4])[0]
        o += 4
        if tag == 0x3ec:                    # HUNK_RELOC32
            while True:
                n = struct.unpack('>I', d[o:o+4])[0]; o += 4
                if n == 0:
                    break
                hn = struct.unpack('>I', d[o:o+4])[0]; o += 4
                offs = [struct.unpack('>I', d[o+4*j:o+4*j+4])[0]
                        for j in range(n)]
                offs.sort(reverse=True)     # original order: descending
                for j, v in enumerate(offs):
                    struct.pack_into('>I', d, o+4*j, v)
                o += 4 * n
        elif tag in (0x3e9, 0x3ea, 0x3eb, 0x3f0):   # code/data/bss/debug
            sz = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff
            o += 4 + sz * 4
        elif tag in (0x3f2, 0x3f3):          # HUNK_END / header
            break
        elif tag == 0:
            continue
        else:
            raise SystemExit('fixup: unknown hunk tag %x at %x' % (tag, o-4))
    open(path, 'wb').write(bytes(d))

if __name__ == '__main__':
    main(sys.argv[1])
