---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2025-10 (byte-identical reconstruction session)
- Wrote `source/mathieeesingbas.s`: verbatim transcription of the whole
  0x1c8-byte CODE hunk.  All 68881 F-line words verified to assemble
  byte-identically under gas `-Wa,-m68881` (fmoves/fmovel/fadds/fsubs/
  fmuls/fdivs/fintrzs/fcmps/fbule/fbuge/fmovel #imm,fpcr).
- Identified the file tail as a compact 16-bit relocation chunk:
  id 0x3f7, `[count:w][hunk:w][off:w]*` + word-0 terminator; 8
  descending offsets 0x28..0x04 (RomTag/InitTable longs).
- `source/fixup.py` rewrites GNU ld's HUNK_RELOC32 tail to the 0x3f7
  form and asserts byte-identity.  `make` => md5
  3e7f4b125c23ac45849af05ebcd587ce = original.  `cmp` clean.
- Kept the prior C+asm model as `make cmodel`.
- `work/oracle.py`: machine68k has no FPU, so the line-F vector ($2c)
  is pointed at a [trap][rte] stub and the needed 68881 subset is
  emulated in python; the saved PC **and stacked SR** in the format-0
  exception frame are patched (rte restores SR — CCR writes must hit
  the frame).  Exercises both init paths, all 4 Open FPCR branches,
  all 12 math vectors (incl. NaN/Inf/-0/div-0), reserved -24, deferred
  and real Expunge with the hand-unlinked list.
  `diff orig.log rebuild.log` is empty.
- Corrected OKF: `fmove.l fpcr,d0` DOES update the integer CCR on a
  data-register destination (prior claim of a random beq was wrong);
  FPCR 0x80 = double-precision + round-nearest (not RZ); removed stale
  Pow/transcendental notes copied from the trans/doub libraries
  (this lib has exactly 12 basics, LVOs -30..-96); vectors doc already
  had the right map (earlier "-52" bound in index was a typo).

## 2025-01 (reconstruction session)
- Hashed binary: 2efea2bb5f27557e846bb0101b00a013f4b66370002f8bfd449247ff5e287c10 (520 bytes, .text 0x1c8).
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
