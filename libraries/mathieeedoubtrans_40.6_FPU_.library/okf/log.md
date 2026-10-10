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
