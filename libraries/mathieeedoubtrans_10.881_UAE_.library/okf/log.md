---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

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
