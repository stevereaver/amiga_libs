---
type: Finding
title: Reconstruction deltas
description: Differences between the rebuilt library and the shipped binary.
---

# Reconstruction deltas

**None.**  `source/mathieeedoubtrans_h0.s` is a verbatim transcription
of the shipped 0x2d4-byte CODE hunk; `fixup.py` rewrites GNU ld's
HUNK_RELOC32 tail into the original compact 0x3f7 form.  `make` output
is byte-identical to the shipped binary (md5
`abb7adf47d2f40b3d8c0bbf852c2875a`, `cmp` clean).

The earlier C+asm model (`make cmodel`) remains in the tree as semantic
documentation; its code layout differs from the shipped binary (GCC
68000 codegen is more verbose: extra register saves, `movea.l 4.w,a6`
reloads, duplicated code tails) and it is not byte-identical.

Notes on the transcription:

- gas `sym1-sym2` in `.short` works inside one object for the
  word-offset functab, so the whole hunk is a single .s file — the
  two-pass `genfunctab.py` link was only needed by the C model.
- Branch sizes: every integer conditional in the hunk is .b (disp8)
  except `bras` to the shared free tail; the FPU branches are
  word-disp by construction (fBcc.W).  gas emitted them all verbatim,
  including `fbole` (cc 5) for Pow's arg<=0 test.
- Pad words: each 18-byte math stub is padded to 20 bytes with
  `.short 0`; Log10's pad lands at endskip-2.  Sincos is 22 bytes +
  pad (extra `fmove.d fp1,(a0)` for the cos pointer).
- All FPU EA forms assemble byte-identically with the old gas syntax:
  `fmoved sp@,%fp0`, `fmoved sp@+,%fp1`, `fmoved %fp0,sp@-`,
  `fintrzd sp@,%fp1`, `fcmpd sp@+,%fp1`, `fmods #0e2,%fp1`,
  `fsincosd sp@,%fp1:%fp0`, `fmoved %fp1,a0@`.
