---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-10
- Parsed 816-byte single-CODE-hunk module: entry `moveq #0,d0/
  rts`, RomTag (AUTOINIT, ver 40, NT_LIBRARY), name/id strings,
  InitTable (dataSize 0x2c, absolute-longword functab,
  InitStruct datatab), 21 vectors + -1L.
- InitStruct decoded: NT_LIBRARY, lib_Flags=6, version 40,
  revision 6, name/idstring pointers.
- init gates on AttnFlags btst #1 (AFF_68020) and #4 (AFF_68881)
  — no NoFPU fallback, unlike the 10.881 builds.
- Vectors mapped via mathieeesingtrans fd (bias 30, 17 funcs):
  each is `fXXXs d0,fp0; fmoves fp0,d0; rts`.  IEEESPSincos uses
  fsincoss fp1:fp0 → sin d0 / cos (a0).  IEEESPPow is a real
  routine (sign fixup for x<0, odd-integer y; non-integer y
  branches to the module entry's moveq#0,rts = return 0.0).
  IEEESPTieee/IEEESPFieee share a bare rts — identity in an
  IEEE-native build.  LVO -24 points at the module entry.
- DELEXP flag lives in a private byte at base+0x2a, not
  lib_Flags — recorded as inconsistency (AMIGALIBS card).
- Reconstructed: C framework + verbatim math.s; `make` builds;
  objdump confirms identical FPU encodings.

## 2026-10-12
- Rewrote the reconstruction as single-object verbatim asm
  (`source/mst406_v.s`): RomTag/strings/InitTable/absolute functab/
  datatab/initfn/lifecycle + all 19 F-line vector bodies emitted as
  raw `.short` pairs.  `make` is **byte-identical** (md5
  `5773e040cf29e8272f16209143db46ec`); reloc tail is ascending, no
  fixup needed.
- New oracle (`work/oracle.py`, adapted from the 10.881 line-F
  harness): identical traces over the init gate matrix (requires
  AFF_68020 AND AFF_68881), all vectors, Pow edge cases, deferred
  and real expunge (Remove+FreeMem through exec LVO stubs).
- Corrected decoding details: rt_EndSkip=0x82 (InitTable, mid-module);
  Pow's `f281 0006` is `fbeq.w +6` (skip sign restore for even
  exponents), `f28e fdde` is `fbne.w` -> CODE+0 (early return 0).
  -102/-108 confirmed as bare-rts stubs sharing 0x258.
