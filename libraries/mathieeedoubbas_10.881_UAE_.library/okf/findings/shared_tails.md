---
type: Finding
title: Shared code tails, shared strings, and the in-CODE seglist cell
description: Space-saving quirks inside the 0x230-byte hunk.
---

# Shared code tails and storage quirks

The original compiler/linker squeezed the hunk by overlapping tails:

- **init-fail / Expunge free tail** (0xca): the no-FPU init branch joins
  the *middle* of Expunge at `moveq #0,d0; FreeMem(base-NegSize,
  Neg+Pos); d0 = segcell; rts`.  On the init path the segcell is still
  0, which doubles as the failure return value.
- **Close -> Expunge fall-through** (0xaa): when OpenCnt reaches 0 and
  LIBF_DELEXP is set, Close falls directly into the Expunge entry.
- **moveq #0,d0; rts** (0xb6): one instruction pair is the reserved
  LVO -24 body, Close's "still open" return, and Expunge's deferred
  return.  The functab entry for -24 holds offset 0x86 -> 0xb6.
- **Cmp -> Tst entry reuse** (0x116): `IEEEDPCmp` with a zero right
  operand tail-branches into `IEEEDPTst` (`beq.s _dptst`), and both
  share the `moveq #1,d0`/`rts` (0x140) and `moveq #-1,d0`/`rts`
  (0x124) epilogues.
- **Name string is a substring** (0xeb): `rt_Name` points one byte past
  the '/' of `"Libs:NoFPU/mathieeedoubbas.library"` (0xe0), so the
  library name shares storage with the fallback path string.
- **Seglist cell lives in CODE** (0x2c), not in the library base: init
  does `lea 0x2c(pc),a1; move.l a0,(a1)`, the free tail reads it back
  with `move.l 0x2c(pc),d0`.  Corollary: the 26 "private" bytes
  allocated by dataSize 0x3c (lib+0x22..0x3b) are never touched --
  dead allocation.
- **rts at hunk+0** (executable entry) is a bare RTS, not the usual
  `moveq #-1,d0; rts` two-word stub seen in later libraries.
- **RomTag rt_Version = 45** while lib_Revision = 881: the AUTOINIT copy
  puts 45 into lib_Version and InitStruct puts 881 into lib_Revision,
  so the library reports version 45.881 even though the IdString says
  "MDB 10.881".  (Same quirk as mathieeesingbas 10.881.)
- **IEEEDPFlt's `moveq #0,d2` look-alike**: the word `7400` at 0x15e is
  the extension word of `fmove.d fp0,-(a7)` (`f227 7400`), not a
  separate `moveq` -- IRA-style F-line-unaware disassemblers misdecode
  it, and likewise at 0x18e/0x1a6/0x1be/0x1d6 in the dyadic ops.
- **Single-precision ±1 constants in Floor/Ceil**: the double-precision
  library still uses `fsub.s`/`fadd.s #imm` with the *single*-precision
  encoding of 1.0 (`3f800000`) to adjust the truncated result -- exact
  in both formats, but a notable encoding choice carried over from the
  singbas source.
