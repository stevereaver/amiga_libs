#!/usr/bin/env python3
# Post-link fixup for queue.library 3.1.
#
# ld emits CODE(0x26b) + DATA(0x1f = template[8] + functab/strings[0x17]).
# The original file is CODE / DATA(8) / CODE(0x17):
#   hunk0 = .text unchanged
#   hunk1 = DATA[0:8]    (InitTable template)
#   hunk2 = DATA[8:]     (absolute functab + "queue.library" + idstr)
#
# Reloc fixups: a reloc whose stored addend points at DATA+0x20.. is
# retargeted to hunk2 (addend -= 0x20, stored long patched); addends
# below 0x20 stay hunk1.  All RELOC32 groups are emitted in the
# original (descending) order.
import struct, sys

H0 = 0x26b            # hunk0 size (longs)
H1 = 8                # hunk1 size (longs)
H2 = 0x17             # hunk2 size (longs)

# original RELOC32 layout: [(target_hunk, [offsets in file order])]
ORIG_R0 = [(0, [0xa, 0x6]),
           (1, [0x86, 0x74, 0x1a]),
           (2, [0x5a, 0x34, 0x16, 0x12])]
ORIG_R1 = [(0, [0x10]),
           (2, [0x8])]
ORIG_R2 = [(0, [0x30, 0x2c, 0x28, 0x24, 0x20, 0x1c, 0x18,
                0x14, 0x10, 0xc, 0x8, 0x4, 0x0])]

d = bytearray(open(sys.argv[1], 'rb').read())
assert struct.unpack('>I', d[0:4])[0] == 0x3f3
o = 4
while True:                                   # name list
    n = struct.unpack('>I', d[o:o+4])[0]; o += 4
    if n == 0: break
    o += n*4
nh = struct.unpack('>I', d[o:o+4])[0]; o += 4
assert nh == 2
assert struct.unpack('>I', d[o:o+4])[0] == 0    # first
o += 4
assert struct.unpack('>I', d[o:o+4])[0] == 1    # last
o += 4
sz0, sz1 = struct.unpack('>II', d[o:o+8]); o += 8
assert sz0 == H0, hex(sz0)
assert sz1 == H1 + H2, hex(sz1)

def parse_hunk(o):
    tag = struct.unpack('>I', d[o:o+4])[0]; o += 4
    sz = struct.unpack('>I', d[o:o+4])[0] & 0x3fffffff; o += 4
    body = bytearray(d[o:o+sz*4]); o += sz*4
    rel = []
    while True:
        t = struct.unpack('>I', d[o:o+4])[0]; o += 4
        if t == 0x3ec:
            while True:
                n = struct.unpack('>I', d[o:o+4])[0]; o += 4
                if n == 0: break
                hn = struct.unpack('>I', d[o:o+4])[0]; o += 4
                for j in range(n):
                    off = struct.unpack('>I', d[o:o+4])[0]; o += 4
                    rel.append((off, hn))
        elif t == 0x3f2:
            break
        else:
            raise AssertionError('tag %x' % t)
    return tag, body, rel, o

t0, b0, r0, o = parse_hunk(o); assert t0 == 0x3e9
t1, b1, r1, o = parse_hunk(o); assert t1 == 0x3ea
assert o == len(d)

h1 = bytearray(b1[:H1*4])
h2 = bytearray(b1[H1*4:])

# remap: (patch_hunk, off, target, addend) -> (patch_hunk', off', target')
# data-hunk patch sites >= 0x20 belong to hunk2; targets into DATA
# with addend >= 0x20 become hunk2 with addend-0x20.
def remap(hpatch, off, target, addend):
    if hpatch == 1 and off >= H1*4:
        hpatch, off = 2, off - H1*4
    if target == 1 and addend >= H1*4:
        target, addend = 2, addend - H1*4
    return hpatch, off, target, addend

got = {0: [], 1: [], 2: []}
for off, hn in r0:
    hp, of, tg, ad = remap(0, off, hn, struct.unpack('>I', b0[off:off+4])[0])
    assert hp == 0
    got[0].append((tg, of, ad))
for off, hn in r1:
    addend = struct.unpack('>I', b1[off:off+4])[0]
    hp, of, tg, ad = remap(1, off, hn, addend)
    got[hp].append((tg, of, ad))

# check sets against the original layout
want = {0: {(tg, of) for tg, l in ORIG_R0 for of in l},
        1: {(tg, of) for tg, l in ORIG_R1 for of in l},
        2: {(tg, of) for tg, l in ORIG_R2 for of in l}}
have = {h: {(tg, of) for tg, of, ad in got[h]} for h in (0, 1, 2)}
assert have == want, (have, want)

# patch stored addends where the target hunk changed (data -> hunk2)
bodies = {0: b0, 1: h1, 2: h2}
for hp, lst in got.items():
    for tg, of, ad in lst:
        struct.pack_into('>I', bodies[hp], of, ad)

# sanity: expected addends
exp = {(0, 0x6): 0x4, (0, 0xa): 0x1e, (0, 0x12): 0x38, (0, 0x16): 0x48,
       (0, 0x1a): 0x4, (0, 0x34): 0x38, (0, 0x5a): 0x48,
       (0, 0x74): 0x0, (0, 0x86): 0x0,
       (1, 0x8): 0x0, (1, 0x10): 0x20}
for (hp, of), v in exp.items():
    gotv = struct.unpack('>I', bodies[hp][of:of+4])[0]
    assert gotv == v, (hp, of, hex(gotv), hex(v))
for i, e in enumerate([0xc4, 0xd6, 0x100, 0, 0x2a2, 0x45e, 0x5f2,
                       0x696, 0x6d8, 0x7e8, 0x898, 0x8f4, 0x95e]):
    gotv = struct.unpack('>I', h2[4*i:4*i+4])[0]
    assert gotv == e, (i, hex(gotv), hex(e))
assert struct.unpack('>I', h2[0x34:0x38])[0] == 0xffffffff
assert bytes(h2[0x38:]) == b'queue.library\0\0\0queue.library 3.1\0#$'

def reloc_block(groups):
    out = bytearray(struct.pack('>I', 0x3ec))
    for tg, offs in groups:
        out += struct.pack('>II', len(offs), tg)
        for x in offs:
            out += struct.pack('>I', x)
    out += struct.pack('>I', 0)
    return out

out = struct.pack('>8I', 0x3f3, 0, 3, 0, 2, H0, H1, H2)
out += struct.pack('>II', 0x3e9, H0) + b0 + reloc_block(ORIG_R0) \
       + struct.pack('>I', 0x3f2)
out += struct.pack('>II', 0x3ea, H1) + h1 + reloc_block(ORIG_R1) \
       + struct.pack('>I', 0x3f2)
out += struct.pack('>II', 0x3e9, H2) + h2 + reloc_block(ORIG_R2) \
       + struct.pack('>I', 0x3f2)
open(sys.argv[1], 'wb').write(out)
