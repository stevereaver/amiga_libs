---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2026-10-10
- Disassembled `version_44.2(WB3.5).library` (ira -M68000 +
  objdump cross-check): single 0x10c code hunk, 7 relocs, sha256
  86cd464a…56d603e.
- Decoded AUTOINIT InitTable: dataSize 0x36, 4-entry word-offset
  function table; Expunge/ExtFunc share the null stub at 0xce.
- Found the 44.x additions vs 40.42: three new base fields
  (self-ptr @0x2a, hardcoded 0x11081999 @0x2e, probe ptr @0x32) and
  a hidden FindSemaphore probe at 0xd2 with an XOR-obfuscated
  10-byte name at 0x100 (decodes to « IPrefs » with key 0xE9).
- Quirks: Expunge vector inert, Close self-expunges at OpenCnt==0,
  RT_ENDSKIP lands mid-pad (odd address 0x10b).
- Reconstructed `source/` (C + header/probe .s, two-pass functab);
  `make` produces a valid .library; probe routine is byte-identical.
