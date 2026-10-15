---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

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
