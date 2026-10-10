---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2026-10-10
- Disassembled `version_39.29(WB3.0).library` (ira -M68000 +
  objdump cross-check): single 0xc0 code hunk, 7 relocs, sha256
  cb03ae35…8d283bb6.
- Decoded AUTOINIT InitTable: dataSize 0x2a, 4-entry word-offset
  function table; Expunge/ExtFunc share the null stub at 0xba.
- Noted quirky semantics: no LIBF_DELEXP anywhere, LibClose
  self-expunges at OpenCnt==0, Expunge vector is inert.
- Reconstructed `source/` (C + header .s, two-pass functab);
  `make` produces a valid .library with matching RomTag, strings,
  vector order and reloc profile.
