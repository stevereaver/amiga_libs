#!/usr/bin/env python3
# Post-link fixup for mathieeedoubbas.library 31.3 (WB1.1):
#  - grow the hunk table to 5 entries (3 real + empty CODE + empty DATA)
#    and append the two empty hunk records before EOF.
#  - rewrite the RELOC32 records verbatim: the original linker split
#    hunk0's relocs into six groups in a non-sorted order, and hunk1's
#    two groups are descending.  Splice in byte-exact replacements.
import struct, sys

path = sys.argv[1]
d = bytearray(open(path, 'rb').read())

assert d[0:4] == b'\x00\x00\x03\xf3'
names = struct.unpack('>I', d[4:8])[0]
sztab = 0x8 + 4*names + 12          # magic + names + first/last/num
first = struct.unpack('>I', d[0x0c:0x10])[0]
nh    = struct.unpack('>I', d[0x10:0x14])[0] - first + 1
assert nh == 3, nh

sz0 = struct.unpack('>I', d[sztab:sztab+4])[0]
sz1 = struct.unpack('>I', d[sztab+4:sztab+8])[0]
sz2 = struct.unpack('>I', d[sztab+8:sztab+12])[0]
sizes = [sz0 & 0x3fffffff, sz1 & 0x3fffffff, sz2 & 0x3fffffff]

# grow hunk table: insert two zero size entries after the 3 real ones
d = bytearray(d[:sztab+12] + b'\x00\x00\x00\x00\x00\x00\x00\x00' + d[sztab+12:])
struct.pack_into('>I', d, 0x10, first + 4)
struct.pack_into('>I', d, 0x08, 5)      # tablesize = 5 hunks

# hunk offsets (body starts after sztab+20 bytes of table)
o = sztab + 20
hunk_tag = []
for i, nl in enumerate(sizes):
    tag = struct.unpack('>I', d[o:o+4])[0]
    assert tag in (0x3e9, 0x3ea, 0x3eb), hex(tag)
    hunk_tag.append((o, o + 8 + nl*4))      # (tag_pos, body_end)
    o += 8 + nl*4
    # skip reloc records to find next hunk tag; remember reloc span
    rel_start = o
    while True:
        t = struct.unpack('>I', d[o:o+4])[0]
        if t == 0x3ec:
            o += 4
            while True:
                n = struct.unpack('>I', d[o:o+4])[0]; o += 4
                if n == 0: break
                o += 4 + 4*n
        elif t == 0x3f2:
            o += 4
            break
        else:
            raise SystemExit('bad tag %x @%x' % (t, o))
    hunk_tag[i] = (hunk_tag[i][0], rel_start, o)   # (tag, rel_start, hunk_end)

# original reloc structure (offsets are within the *source* hunk)
H0_RE = b'\x00\x00\x03\xec' + b''.join(
    struct.pack('>II', len(offs), tgt) + b''.join(struct.pack('>I', v) for v in offs)
    for tgt, offs in [
        (0, [0x12, 0xe, 0x2]),
        (0, [0x106, 0xa4, 0xa0, 0x9c, 0x98, 0x6a, 0x64, 0x60, 0x5c]),
        (0, [0x6]),
        (0, [0x16]),
        (1, [0xcc, 0xc8, 0xc4, 0xc0, 0xbc, 0xb8, 0xb4, 0xb0, 0xac, 0xa8]),
        (0, [0x7a]),
    ]) + b'\x00\x00\x00\x00'

H1_RE = b'\x00\x00\x03\xec' + b''.join(
    struct.pack('>II', len(offs), tgt) + b''.join(struct.pack('>I', v) for v in offs)
    for tgt, offs in [
        (1, [0x232, 0x228, 0x212, 0x1fe, 0x1f4, 0x1ea, 0x1de, 0x1d0,
             0x1c6, 0x1ba, 0x1a6, 0x19a]),
        (2, [0xdc, 0xf2, 0x110, 0x134, 0x150, 0x16c, 0x188]),
    ]) + b'\x00\x00\x00\x00'

# verify the sets match what ld emitted, then splice
def splice(hi, blob):
    tag_pos, rel_start, hunk_end = hunk_tag[hi]
    old = bytes(d[rel_start:hunk_end-4])          # minus END tag
    # sanity: same reloc set
    def offsets(buf):
        s = {}
        if buf[:4] != b'\x00\x00\x03\xec': return s
        p = 4
        while True:
            n = struct.unpack('>I', buf[p:p+4])[0]; p += 4
            if n == 0: break
            t = struct.unpack('>I', buf[p:p+4])[0]; p += 4
            s.setdefault(t, []).extend(
                struct.unpack('>I', buf[p+4*j:p+4*j+4])[0] for j in range(n))
            p += 4*n
        return {k: sorted(v) for k, v in s.items()}
    a = offsets(old); bb = offsets(blob)
    assert a == bb, (hi, a, bb)
    d[rel_start:hunk_end-4] = blob
    delta = len(blob) - (hunk_end - 4 - rel_start)
    for j in range(hi+1, 3):
        hunk_tag[j] = tuple(x + delta for x in hunk_tag[j])

splice(0, H0_RE)
splice(1, H1_RE)
# hunk2: ld emits just END; original has just END too -> nothing.

# append two empty hunk records before final END
assert d[-4:] == b'\x00\x00\x03\xf2'
d = d + b'\x00\x00\x03\xe9\x00\x00\x00\x00\x00\x00\x03\xf2' \
      + b'\x00\x00\x03\xea\x00\x00\x00\x00\x00\x00\x03\xf2'

open(path, 'wb').write(bytes(d))
print('fixup: 5-hunk header + verbatim relocs + empty trailer hunks')
