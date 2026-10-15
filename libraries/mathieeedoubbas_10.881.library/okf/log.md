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

- Wrote `source/mathieeedoubbas_h0.s`: verbatim reconstruction of the
  0x230-byte CODE hunk — bare-rts entry, RomTag @0x02, InitTable,
  seglist cell @0x2c, word-offset functab (16 vectors), InitStruct
  data, init/Close/Expunge/Open + all 12 IEEE DP FPU ops, mid-string
  name pointer, string islands, per-function `0000` pad words.
- `fixup.py` rewrites the reloc tail into the original 0x3f7 DREL16
  chunk (8 refs, descending). Output byte-identical
  (md5 `d045e9dab808f9331ad97bfc85e795dd`).
- Corrected stale findings: Open writes FPCR:=0x10 unconditionally
  (not the conditional rewrite previously described); the no-FPU init
  path frees the NEW lib base (not the OpenLibrary result) and returns
  0; this build has no Pow vector (16 LVOs, -6..-96).
- New `work/oracle.py`: machine68k + python 68881 line-F subset using
  USP for stack EAs; identical traces original vs rebuild including
  no-FPU init (openlib path name, closelib 0, freemem of the fresh
  lib), FPCR write, all math vectors, deferred + real expunge.
- Mirrored identical rebuild to the `_UAE_` twin (same md5).
