---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-15
- Rewrote the reconstruction as a single verbatim asm file,
  `source/mdb406_v.s` (same approach as the singtrans
  mst406_v.s): RomTag/InitTable/functab/datatab emitted in
  module order, every F-line word as raw `.short`, literal-0
  functab slot left for RELOC32.  `make` now links
  `-nostdlib -Wl,-s` to a **byte-identical** copy of the
  shipped binary (md5 0b7251cd2ae0bdfe0719761b54a6eb0b);
  the old C model survives as `make cmodel`.
- New `work/oracle.py` (machine68k + python 68881 emulator,
  double-precision stack EAs `(sp)+/-(sp)/(sp)` resolved via
  USP): init gate matrix, open x2 (FPCR becomes 0x90 — Open
  writes `moveq #72; add.l d0,d0; fmove.l d0,fpcr`), all 12
  math vectors over edge inputs incl. NaN/inf/-0 and the
  four FPCR rounding modes for Fix, deferred + real expunge.
  Original vs rebuild logs diff clean -> runtime-identical.
- Correction: Open is NOT the plain open stub — it programs
  the FPCR to double-precision/round-toward-zero, so
  `IEEEDPFix` truncates for any caller that went through
  Open (see FixRounding).
- RT_ENDSKIP = RT_INIT = hunk+0x7e, pointing at the
  InitTable itself — mid-module quirk shared with the
  sibling 40.6 builds.

## 2026-10-10
- Parsed 896-byte single-CODE-hunk module: entry `moveq #0,d0/
  rts`, RomTag (AUTOINIT, ver 40), InitTable (dataSize 0x2c,
  absolute-longword functab), InitStruct datatab.
- Same Berndt framework as mathieeesingtrans 40.6: AttnFlags
  gate on AFF_68020 && AFF_68881, private DELEXP byte at +0x2a.
- Vectors mapped via mathieeedoubbas fd (bias 30, 12 funcs):
  Fix/Flt/Cmp/Tst/Abs/Neg/Add/Sub/Mul/Div/Floor/Ceil.
- FPU ops decoded via scratch assembly: doubles ride the stack
  (fmoved sp@+/fop sp@/fmoved fp0,sp@), fp0 result popped into
  d0/d1.  Add/Mul push both operands at once; Sub/Div push left
  first so fp0 = left OP right.
- IEEEDPFix uses `fmove.l fp0,d0` — converts under the CURRENT
  FPCR rounding mode, not guaranteed truncation (finding).
- IEEEDPFloor: fintrz for x>=0; for x<0 sets FPCR=0x20
  (round->-inf) and uses fint, restoring FPCR.  IEEEDPCeil =
  -floor(-x), skipping the sign restore on +0.
- IEEEDPCmp: branch-tree integer compare with +0==-0 handling;
  IEEEDPTst: add.l d0,d0 sign/zero test.  Abs=bclr#31, Neg=bchg#31.
- Reconstructed: C framework + integer vectors, math.s verbatim
  vectors; builds; encodings match original.
