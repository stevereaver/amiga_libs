---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2025-10 (byte-identical reconstruction session)
- Wrote `source/mathieeesingtrans.s`: verbatim transcription of the whole
  0x244-byte CODE hunk.  All 68881 F-line words verified to assemble
  byte-identically under gas `-Wa,-m68881` (fmovel fpcr, fmove.s/x to
  and from fpn, flog2/flogn/flog10/fsin/fcos/ftan/fsincos/fsinh/fcosh/
  ftanh/fasin/facos/fatan/fetox/ftwotox/fsqrt/fintrz/fneg/fmul/fmod/
  fcmp, fbeq/fbne/fbogt, fsincos fp1:fp0 pair, fmove.s fp1,(a0)).
- Decoded rt_Name: points 11 bytes into the "Libs:NoFPU/..." path string
  — the library name is the path tail, no standalone name string.
- Verified the no-FPU init path against the hunk bytes: the fresh base is
  pushed, the fallback lib opened AND immediately closed (result unused,
  NULL or not), the base popped into a1 (not d1) and freed by the shared
  Expunge tail at 0xe8.  Corrected the stale okf/C-model claim that the
  fallback library's base was freed.
- Corrected the stale okf/C-model claim that `fmove.l fpcr,d0` leaves
  CCR untouched: a transfer into an integer data register DOES set N/Z,
  so Open's beq genuinely tests fpcr == 0 (same correction as singbas).
- File tail is the compact 16-bit 0x3f7 reloc chunk: 8 descending
  offsets 0x28..0x04 — identical layout to mathieeesingbas, so
  `source/fixup.py` reuses that pattern verbatim.  `make` => md5
  72797e9959324e0eede21e4573c3d7d3 = original.  `cmp` clean.
- Kept the prior C+asm model as `make cmodel` (LibInit no-FPU branch
  fixed to free the new base, matching the shipped flow).
- `work/oracle.py`: machine68k has no FPU; line-F vector ($2c) points at
  a [trap][rte] stub and the needed 68881 subset is emulated in python,
  including fp1 (Pow fintrz/fcmp/fmod path, Sincos cos store), the
  full 32-entry fBcc table, and integer CCR patching of the stacked SR.
  Exercises both init paths (OpenLibrary succeeding and failing, null
  base), all 4 Open FPCR branches, every user vector with NaN/Inf/-0/
  domain edges, reserved -24, deferred + real Expunge, Close fall-through.
  `diff orig.log rebuild.log` is empty — runtime-identical.  This
  twin's log is byte-identical to the non-UAE dir's log.
- New Pow quirks confirmed by the oracle: 0^negative -> 0x7fffffff NaN
  (not +inf), 0^NaN -> NaN, (-0)^odd -> +0 (sign lost), (-2)^(+inf) ->
  -inf and (-2)^(-inf) -> -0 (fmod(inf,2)=NaN -> NE -> sign applied).
- Updated OKF: status DONE; documented rt_Name-in-path, Tieee/Fieee
  shared rts, Pow->LibNull branch, Lnan bchg trick, 0x3f7 tail.

## 2025-01 (reconstruction session)
- Hashed binary: 960d90a9d0b4346b027f00f7c0dae9a3c3234cfe88fccdd743af99e6fc0aef3b (644 bytes, .text 0x244).
- Confirmed UAE twin byte-identical.
- IRA -M68020 disassembly + objdump -D used to decode the 68881 F-line
  words (IRA's 68000 pass leaves them as data).
- Decoded AUTOINIT header: rts entry, RomTag v45, InitTable datasize 0x3c,
  word-offset function table at 0x30, seglist cell at 0x2c.
- Decoded InitStruct stream a00e0600 90160371 0000
  (flags=0x06, revision=881).
- Mapped every LVO to the NDK fd13 definitions; all resolved.
- Reconstructed source/ (resident header asm, generated functab via
  two-pass link + genfunctab.py, datatab asm, math.s with verbatim FPU
  sequences, C framework for Open/Close/Expunge/init).
- `make` produces a valid HUNK .library; FPU instruction streams verified
  byte-identical against the shipped disassembly; framework code is
  semantically equivalent but larger (see findings).
