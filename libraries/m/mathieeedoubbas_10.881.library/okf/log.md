---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2026-10-15 (byte-identical reconstruction session)
- Wrote `source/mathieeedoubbas_h0.s`: verbatim transcription of the
  whole 0x230-byte CODE hunk.  All 68881 F-line words verified to
  assemble byte-identically under gas `-Wa,-m68881`
  (`fmovel d0,fpcr`, `fmoved (a7)+/(a7)` loads, `fmoved fp0,-(a7)/(a7)`
  stores, `fmovel d0,fp0`/`fp0,d0`, `faddd/fsubd/fmuld/fdivd (a7),fp0`,
  `fintrzx`/`fcmpx fp1,fp0`, `fbule`/`fbuge`, `fsubs`/`fadds #0e1,fp0`).
- Reloc tail is the same compact 0x3f7/DREL16 form as singbas: 8
  descending offsets 0x28..0x04 (matchtag, endskip, name, idstr, init,
  functab, datatab, initfunc; the scalar dataSize @0x1c is NOT
  relocated).  `source/fixup.py` rewrites GNU ld's RELOC32 tail.
  `make` => md5 d045e9dab808f9331ad97bfc85e795dd = original. `cmp` clean.
- Kept the prior C+asm model as `make cmodel`; fixed its LibInit
  no-FPU path (it freed the OpenLibrary result -- the shipped code
  frees the *new* base popped into a1 via `movea.l (a7)+,a1`).
- `work/oracle.py`: machine68k has no FPU -> line-F vector ($2c) points
  at a [trap][rte] stub, python emulates the exact 68881 subset.  New
  vs the singbas shim: memory-EA doubles on the user stack are read/
  written through the USP register (inside the trap A7 = ISP, the
  trapped code ran in user mode), FPCR rounding-mode bits (5:4) are
  honoured for `fmove.l fp0,d0` and dyadic ops via exact Fraction
  arithmetic, and OpenLibrary(-552)/CloseLibrary(-414) are stubbed for
  the `Libs:NoFPU/` init path.  Exercises both init paths, Open
  (unconditional FPCR=0x10), all 12 math vectors incl. NaN/Inf/-0/
  denormal/div-0 and FPCR-mode effects on Fix, reserved -24, deferred
  and real Expunge with the hand-unlinked list.
  `diff orig.log rebuild.log` is empty.
- Corrected OKF: the earlier `nofpu_init` finding claimed the free tail
  freed the OpenLibrary result (misread `225f`) -- it frees the new
  base; oracle shows freemem on new_base-NegSize and closelib on the
  fallback result.  `fpcr_open` now documents the unconditional
  `moveq #0x10,d0; fmove.l d0,fpcr` (ext precision + RZ).  Removed stale
  Pow/transcendental notes (this lib has only the 12 basics,
  LVOs -30..-96).  Fixed vectors.md "-52" typo and the off-by-2 RomTag
  field offsets in structures/autoinit.md.
- Mirrored the identical rebuild (same source, same md5) into the
  `_UAE_` twin directory, incl. quoting of the parenthesised original
  path in its Makefile.

## 2025-01 (reconstruction session)
- Hashed binary: 398aa5cc85e5c7124d5f13861d83ede69f562136c77ba27f0381705775083df0 (624 bytes, .text 0x230).
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

