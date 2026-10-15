---
type: Log
title: Reconstruction log
---

# Log — mathieeedoubtrans_40.6_FPU_.library

- Scanned: 1000-byte hunk; same Martin Berndt AUTOINIT
  framework as mathieeedoubbas/mathieeesingtrans 40.6 --
  private DELEXP byte, SysBase/seglist in base, EndSkip->
  InitTable quirk.
- Phase 1: absolute-longword functab decoded -- 4 system +
  ExtFunc->hunk+0 + 17 vectors matching the NDK
  mathieeedoubtrans fd order exactly (Atan..Log10).
- Phase 2: vectors decoded -- 13 identical push/fXXXd/pop
  monadic stubs, fsincos (FPc:FPs = cos:sin) for Sincos,
  a real IEEEDPPow (negative-x integer-y sign logic,
  fmodd #2 odd/even test, FPCR save/restore), Tieee/Fieee
  float<->double converters.  LibInit gate = btst#1 &&
  btst#4 on AttnFlags.
- Phase 3: framework in C, vectors in math.s via a DSTUB
  macro.  Vector region 0x194..0x336 verified BYTE-EXACT
  (0 diffs); FPCR/FPU encodings all identical.
- Phase 4: this OKF bundle.

## 2026-10-15
- Wrote `source/mdt406_v.s`: single-file verbatim asm of the
  whole hunk (RomTag/InitTable/functab/datatab + all code),
  raw `.short` for every F-line word, same style as the
  sibling mdb406_v.s.  `make` (m68k-amigaos-gcc -m68000,
  -nostdlib -nostartfiles -Wl,-s) produces a BYTE-IDENTICAL
  module: md5 8c1838e982391b3ffcf50302f79ae4e6 both sides,
  0 diffs, no reloc fixup needed (31 RELOC32 entries emitted
  in source order).  C model kept under `make cmodel`.
- Wrote `work/oracle.py` (adapted from the mathieeedoubbas
  40.6 oracle): machine68k + python 68881 line-F emulator.
  Added .s single<->double EA formats for Tieee/Fieee.
  Drives init-gate matrix, open x2 (confirms Open does NOT
  touch FPCR -- unlike doubbas), all 17 vectors over edge
  inputs, Pow negative-x odd/even/non-integer paths and FPCR
  save/restore, Sincos cos->(a0) store, deferred + real
  expunge.  orig.log == rebuild.log (1269 lines): RUNTIME-
  IDENTICAL.
