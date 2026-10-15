---
type: Finding
title: Reconstruction deltas
description: Differences between the rebuilt library and the shipped binary.
---

# Reconstruction deltas

**None.**  `source/mathieeesingtrans.s` is a verbatim transcription of
the shipped 0x244-byte CODE hunk; `fixup.py` rewrites GNU ld's
HUNK_RELOC32 tail into the original compact 0x3f7 form.  `make` output
is byte-identical to the shipped binary (md5
`72797e9959324e0eede21e4573c3d7d3`, `cmp` clean).

The earlier C+asm model (`make cmodel`) remains in the tree as semantic
documentation; its code layout differs from the shipped binary (GCC
68000 codegen is more verbose: extra register saves, `movea.l 4.w,a6`
reloads, duplicated code tails) and it is not byte-identical.

Notes on the transcription:

- gas `sym1-sym2` in `.short` works inside one object for the
  word-offset functab, so the whole hunk is a single .s file — the
  two-pass `genfunctab.py` link was only needed by the C model.
- Branch sizes: every conditional in the hunk is .b (disp8) except the
  FPU branches which are word-disp by construction (fBcc.W).
- Pad words: each 10-byte FPU stub is padded to 12 bytes with `.short 0`;
  Log10's pad lands at endskip-2.
