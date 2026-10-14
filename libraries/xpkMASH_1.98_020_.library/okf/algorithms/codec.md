---
type: Algorithm
title: MASH 1.98 codec
---

# Wire format (MSB-first bit stream, mixed literal/command stream)

Bit-packed LZ77 over a 32 KB window (max encoded distance 32415 =
0x7e9f).  Identical framing to MASH 1.16/2.0:

```
run:    '0'                       -> 0 literals
        '1'^n '0'                 -> n literals (n = 1..5)
        '1'^6 '1'^k '0' + g(k+1)  -> run = rclass[k+1].base + g + 6
match:  '00' + dist(9b)                  -> len 2
        '01' + class3 + bcs-gamma        -> len 3
        '1'  + '1'^k '0' + g(k+1)        -> len-2 = lclass[k].base+g
          then class3 + bcs-gamma dist   -> dist <= 32415
```

Tables embedded in the hunk:

- `runw[8]`  @0x7b0  — literal-run classes (word = code<<8|nbits-1)
- `lenw[16]` @0x7c0  — length classes for len-2 in 0..15
- `distw[8]`/`distor[8]` — distance classes {bits,span} + class<<bits-3
- decoder copies of the same at 0x9ac..0xa48 (incl. the mirror table
  `0x8000,0x4000,...` and the `_runc` tail `...0x7ffe,0x0001,0xfffe`)
  (all table offsets are -0x10 / -0x14 vs the 000 build)

# Emitter (V2.0 hybrid)

A flag-slot byte is reserved when a bit group opens; once 8 pending
bits remain a whole raw byte is written to the output cursor
mid-field, then a fresh flag slot is reserved.  Gamma fields use a
unary-class long pattern with doubling spans (16-bit span register —
see defects).

# The two engines ("2 mixed streams")

## Engine A — gap-array matcher (inlen < 0x10001, big alloc ok)

Allocates `0x20010 + 2*inlen`:

- `wk+0`: head[64K] word table, rolling 16-bit key (two-byte hash)
- `wk+0x20000`: gap/link array; pass2 writes 6-byte
  `{pos.w, dist.w<<16|len-2}` match records over it

- pass1 (0x396): `gaps[i]` = distance to previous occurrence of the
  byte pair at i (or -1).  Phase A first ~32K positions with no
  distance clamp; phase B clamps gap >= 32415 to -1.
- pass2 (0x45a region; record-emit helper `_flush` at 0x450): lazy
  gap-chain matcher; candidate next-byte filtering and distance
  checks; emits records.
- coreA (0x610): walks records emitting the mixed stream.

## Engine B — hash-chain matcher (fallback / big inputs)

`AllocMem(0x10000)` chain table + halving work alloc
(0x20000 -> 0x2000, five tries):

- 64KB chain table at alloc+0x8000, indexed by sign-extended
  position word *2 — NOT bulk cleared; only the seed slot
  `chain[in.w]` gets -1
- head table is `512 << shift` bytes where shift = 8 - log2(worksz
  >>13) (matches the halving loop), head[h] = (b1<<shift)&0xff00 | b0
- same emit path as engine A (the streams are wire-identical;
  selection may differ in edge cases)

# Decoder (0x89a)

Straight-line decoder, BCS-seeded gammas, whole-byte grab on a dry
accumulator mid-distance-field.  A 0x00 flag byte consumed inside a
distance gamma loses its trailing zeros (defect, reproduced).
Ends on the '00' marker; can write 2 bytes past OutBuf end.

# Mode

`xsp_Mode` (default 100) only feeds `tries = 1 << (mode/10)` stored
at xsp+0x40 — used to size the hash head table.  The streams
produced for mode 100 vs mode 0 are identical on the test corpus
except where mode changes hash-table dimensions.

# 000 vs 020

Same algorithm and identical output streams.  Differences are purely
codegen: the 020 build uses scaled-index addressing to fuse 000's
`lea (a3,d1.l),a5; adda d1,a5` into `lea (a3,d1.l*2),a5`,
`tst.w -4(a2,d3.w*2)` etc.  The 2-byte alignment fill at 0x356 is
`0x4b90` (`chk.w (a0),d5`) vs the 000's `0x001c` — dead in both
(the clear loop is entered via `bsr.w $358` in each).  Code hunk is
20 bytes shorter (2632 vs 2652).
