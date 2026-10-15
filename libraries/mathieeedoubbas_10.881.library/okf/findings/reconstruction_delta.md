---
type: Finding
title: Reconstruction deltas
description: Differences between the rebuilt library and the shipped binary.
---

# Reconstruction deltas

None — `make` in `source/` now produces a **byte-identical** image
(md5 `d045e9dab808f9331ad97bfc85e795dd`, sha256
`398aa5cc85e5c7124d5f13861d83ede69f562136c77ba27f0381705775083df0`).

The byte-exact build is `mathieeedoubbas_h0.s`, a verbatim assembly
reconstruction of the single CODE hunk (0x230 bytes), linked by
`fixup.py` which rewrites GNU ld's RELOC32 tail into the original
compact 16-bit `0x3f7` RELOC32SHORT chunk with the 8 RomTag/InitTable
refs in descending offset order. The earlier C model
(`mathieeedoubbas.c`, `math.s`, `genfunctab.py` two-pass functab) is
kept as a readable reference (`make cmodel`) but was never
byte-identical.

Notes on the original image:

- Entry stub is a bare `rts` (not `moveq #-1,d0;rts`).
- Reserved LVO -24 is `moveq #0,d0;rts` at 0xb6, which is also the
  shared return-zero tail of Close/Expunge.
- lib name pointer targets mid-string inside
  `"Libs:NoFPU/mathieeedoubbas.library"` -> `"mathieeedoubbas.library"`;
  the IdString is `"MDB 10.881"`.
- gas canonicalization traps avoided: `bras` (not `braw`) for the
  no-FPU fallthrough, `subaw` (not `subal`) in the NegSize tail,
  `fintrzx`/`fcmpx`/`fbule`/`fbuge` F-line mnemonics.
- Runtime: `work/oracle.py` emulates the 68881 line-F subset (USPs
  stack for `(a7)` EAs since the trap runs on ISP) and gives identical
  traces for original and rebuild across no-FPU init, Open FPCR write,
  all 12 math vectors (NaN/Inf/-0/div0), and deferred + real expunge.
