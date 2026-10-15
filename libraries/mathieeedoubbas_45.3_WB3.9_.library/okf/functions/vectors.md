---
type: Function
title: Vector map
description: LVO map — three word-offset functabs, same 16 vectors.
timestamp: 2026-10-15T16:40:00Z
---

# Vector map (LVO -6 .. -96)

All three functabs are word-offset tables (0xffff marker, 16 signed
word offsets relative to the table start, 0xffff terminator):
software @0x184, 68881 @0x1a8, 68040/fpsp @0x1cc.

Doubles travel in d0:d1 (operand 1) / d2:d3 (operand 2); dyadic
ops do `d0:d1 OP d2:d3` internally via the user stack.

| LVO | function | tabB (software) | tabC (68881) | tabD (040/fpsp) |
|-----|----------|-----------------|--------------|-----------------|
| -6  | LibOpen       | 0x14c | 0x14c | 0x14c |
| -12 | LibClose      | 0x168 | 0x168 | 0x168 |
| -18 | LibExpunge    | 0x112 | 0x112 | 0x112 |
| -24 | reserved      | 0x0f2 | 0x0f2 | 0x0f2 |
| -30 | IEEEDPFix     | 0xbdc | 0xcb4 | 0xcb4 |
| -36 | IEEEDPFlt     | 0xb9c | 0xca4 | 0xca4 |
| -42 | IEEEDPCmp     | 0x560 | 0x560 | 0x560 |
| -48 | IEEEDPTst     | 0x898 | 0x898 | 0x898 |
| -54 | IEEEDPAbs     | 0x31c | 0x31c | 0x31c |
| -60 | IEEEDPNeg     | 0x324 | 0x324 | 0x324 |
| -66 | IEEEDPAdd     | 0x8c4 | 0xd54 | 0xd54 |
| -72 | IEEEDPSub     | 0x8b8 | 0xd6c | 0xd6c |
| -78 | IEEEDPMul     | 0x606 | 0xd88 | 0xd88 |
| -84 | IEEEDPDiv     | 0x32c | 0xda0 | 0xda0 |
| -90 | IEEEDPFloor   | 0x21e | 0xcc4 | 0xd04 |
| -96 | IEEEDPCeil    | 0x1f0 | 0x1f0 | 0x1f0 |

## Lifecycle (shared)

- **LibOpen** @0x14c: `jsr (a0)` on the lib+0x34 hook (stub returns 0;
  FPCR-init on 68881-flavoured bases); on nonzero it would return 0,
  else `addq.w #1,lib_OpenCnt`, `bclr #3,lib_Flags` (clears
  LIBF_DELEXP instead of refusing), `move.l a6,d0`.
- **LibClose** @0x168: `jsr (a0)` on the lib+0x38 hook (always the
  `clr.l d0;rts` stub, result ignored); `subq.w #1,lib_OpenCnt`;
  if LIBF_DELEXP (bit3, lib_Flags @+0x0e) set it *falls into* the
  expunge body which re-tests OpenCnt — deferred expunge only runs
  at count 0.
- **LibExpunge** @0x112: opencnt!=0 -> `bset #3,lib_Flags`, return 0.
  Else manual ln_Succ/ln_Pred unlink (no exec Remove call),
  execbase from lib+0x28, `jsr -210` FreeMem(base-negsize,
  negsize+possize = 96+64 = 160), returns the seglist stashed in the
  code cell @0x17e by init.
- **reserved -24** @0x0f2: `moveq #0,d0; rts`.
- entry @0 (module entry / first long of hunk): `moveq #-1,d0; rts`.

## Math vectors

- **IEEEDPFix**: FPU `fmove.d (sp)+,fp0; fmove.l fp0,d0` — result
  honours the FPCR rounding mode (RZ after open on the 68881 path,
  RN on the fpsp path where the hook is not installed).  Software
  version @0xbdc is pure integer and truncates.
- **IEEEDPFlt**: FPU `fmove.l d0,fp0; fmove.d fp0,-(sp); pop d0:d1`.
- **IEEEDPCmp** @0x560 / **IEEEDPTst** @0x898: integer branch trees
  (exponent+mantissa compares; +0 == -0).
- **IEEEDPAbs** = `bclr #31,d0`, **IEEEDPNeg** = `bchg #31,d0`.
- **Add/Sub/Mul/Div**: FPU variants push/pop doubles through (sp)
  (`faddd`/`fsubd`/`fmuld`/`fdivd`); Sub negates the right operand
  sign first.  Software variants share helpers; the software floor
  helper even calls the lib's own -66 (Add) vector via `jsr -90(a6)`-
  style self-dispatch (@0x28a: `jsr a6@(-66)`).
- **IEEEDPFloor**: 68881 @0xcc4 — x>=0 `fintrz.d`, x<0 save FPCR,
  load 0x20 (round-to-minus-inf), `fint.x`, restore FPCR.
  040 @0xd04 — same split but via `jsr -30(a0)` on the fpsp.resource
  base (d0=3 truncate, d0=1 fint under FPCR=0x20, operand in fp0).
  Software @0x21e pure integer.
- **IEEEDPCeil** @0x1f0 (single shared body): `bchg #31,d0;
  jsr -90(a6)` then a zero-result guard that skips the sign
  restore — i.e. ceil(x) = -floor(-x) with +0 handling, so Ceil
  automatically follows whichever Floor the chosen functab bound.
