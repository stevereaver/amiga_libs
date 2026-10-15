---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2025-10 (byte-identical upgrade)
- Replaced the approximate C-model build with a verbatim single-file
  `source/mathieeesingbas.s` transcription (RomTag, AUTOINIT table,
  word-offset functab, InitStruct stream, all code, strings, pads).
- Decoded the reloc tail as hunk type 0x3f7: {count:word, hunk:word,
  8 x u16 offsets descending}; `fixup.py` rewrites GNU ld's RELOC32 tail.
- `make` now yields md5 3e7f4b125c23ac45849af05ebcd587ce = binary/ (cmp clean).
- machine68k oracle (`work/oracle.py`): parses 0x3f7/0x3ec relocs, traps
  + emulates every F-line instruction (soft 68881), exercises init
  (FPU present/absent), all Open FPCR branches incl. the stale-Z beq,
  every LVO incl. unordered FCMP paths, deferred + real expunge.
  Original vs rebuild logs identical.
- New findings: drel_tail, uninit_version (datatab never writes
  lib_Version/lib_IdString -> both stay 0).  Fixed fpcr_open mode-byte
  decode (0x80 = double precision + RN, not extended + RZ) and the
  vectors.md LVO range.

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

## 2026-11-20

- Binary is byte-for-byte identical to the non-UAE twin (same md5
  `3e7f4b125c23ac45849af05ebcd587ce`), so the verbatim asm source
  and fixup.py were shared across. `make` now produces the
  byte-identical rebuild; `make cmodel` keeps the C model.
- Oracle run: traces identical original vs rebuild (184-line log).
- Status: DONE.
