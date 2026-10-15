---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2026-10 (byte-identical reconstruction session)
- Wrote `source/mathieeedoubtrans_h0.s`: verbatim transcription of the
  whole 0x2d4-byte CODE hunk.  All 68881 F-line words verified to
  assemble byte-identically under gas `-Wa,-m68881` (fmove.l d0,fpcr,
  fmove.d (a7)/(a7)+,-(a7)/(a0) and fp->EA forms, fmove.s d0/fp0,
  flog2/flogn/flog10/fsin/fcos/ftan/fsincos/fsinh/fcosh/ftanh/fasin/
  facos/fatan/fetox/ftwotox/fsqrt/fintrz/fneg/fmul/fmod/fcmp .d/.x/.s,
  fsincos.d (a7),fp1:fp0, fmove.d fp1,(a0), fbeq/fbne/fbogt/fbole .w).
- Same family layout as the singtrans/doubbas siblings: bare-rts entry,
  RomTag v45 @0x02, InitTable @0x1c (dataSize 0x3c NOT relocated),
  seglist cell @0x2c, word-offset functab (21 vectors, -6..-126),
  InitStruct a00e0600 90160371 0000 (flags=6, rev=881).
- Confirmed rt_Name points 11 bytes into the "Libs:NoFPU/..." path —
  the library name is carved out of the fallback path tail.
- No-FPU init path verified against the hunk bytes AND the oracle:
  fresh base pushed, fallback lib opened AND immediately closed
  (result unused, NULL or not), base popped into a1 (not d1) and
  freed by the shared Expunge tail at 0xd4; returns the still-zero
  segcell -> init fails.  Corrected the stale okf claim that the
  OpenLibrary result was freed / the pop went into d1.
- Corrected the stale okf claim about Open: THIS library writes
  FPCR := 0x10 unconditionally (`moveq #0x10,d0; fmove.l d0,fpcr`),
  same as mathieeedoubbas — the conditional 0x40..0x80 -> 0x80 scheme
  in the old finding describes mathieeesingtrans, not this binary.
- Corrected the stale Fieee claim: the shipped code does
  `fmove.s d0,fp0` — a genuine single->double conversion, not the
  `fmove.l` integer load previously documented (no bug).
- File tail is the compact 16-bit 0x3f7 reloc chunk: 8 descending
  offsets 0x28..0x04 — identical layout to all 10.881 siblings, so
  `source/fixup.py` reuses that pattern (assert sz == 0xb5).
  `make` => md5 `abb7adf47d2f40b3d8c0bbf852c2875a` = original.
  `cmp` clean.
- `work/oracle.py`: machine68k has no FPU; line-F vector ($2c) points
  at a [trap][rte] stub and the needed 68881 subset is emulated in
  python.  (a7) operands inside FPU insns are resolved through
  Register.USP (Register.A7 is the supervisor stack mid-trap).
  Exercises both init paths (OpenLibrary succeeding and failing, null
  base), Open's unconditional FPCR write, every user vector with
  NaN/Inf/-0/domain edges, reserved -24, deferred + real Expunge,
  Close fall-through.  `diff orig.log rebuild.log` is empty —
  runtime-identical.  The UAE twin's log is byte-identical too.
- Pow quirks confirmed by the oracle: 0^negative -> 0x7fffffff:ffffffff
  NaN (not +inf), 0^NaN -> NaN, (-0)^odd -> +0 (sign lost via the
  shared moveq#0 tail — d1 keeps the arg low word), (-2)^(+inf) ->
  -inf and (-2)^(-inf) -> -0 (fmod(inf,2)=NaN -> NE -> sign applied).
- Mirrored identical rebuild to the `_UAE_` twin (same md5; orig.log
  matches the main dir's byte-for-byte).
- Updated OKF: status DONE; added hunk_tail.md and shared_tails.md;
  corrected fpcr_open.md, nofpu_init.md, pow_edges.md,
  reconstruction_delta.md, vectors.md, IEEEDPFieee.md,
  fpu_evaluation.md.

## 2025-01 (reconstruction session)
- Hashed binary: 14957a826dd80d83ffe7f3dc7583882058d2c00939fa3c1ad310cc17653ddb1d (788 bytes, .text 0x2d4).
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
