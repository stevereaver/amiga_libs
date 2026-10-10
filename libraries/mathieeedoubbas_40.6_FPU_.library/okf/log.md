---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

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
