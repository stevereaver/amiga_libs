---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

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

## 2026-10-15 (byte-exact upgrade)

- Mirrored `mathieeedoubbas_h0.s` + `fixup.py` + oracle from the
  non-UAE twin (identical binary, md5 `d045e9dab808f9331ad97bfc85e795dd`).
  Byte-identical build; oracle traces identical.
- Stale findings corrected (unconditional FPCR write; no-FPU path frees
  the new lib base; no Pow vector in this 16-LVO build).
