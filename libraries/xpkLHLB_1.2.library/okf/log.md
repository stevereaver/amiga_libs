---
type: Log
title: Work Log
description: Chronological journal of analysis sessions.
---

# Log

## 2026-10-15
- Parsed hunk: single CODE hunk 0x2ff longs @file 0x20; AUTOINIT
  RomTag +0x04, InitTable +0x1e (word-offset functab +0x2e,
  datatab +0x46, initfn +0x160).
- Generated source/xpkLHLB_h0.s via work/gen_source.py: raw
  bytes for header/strings/descriptor blocks and the two static
  table spans (+0x57a..+0x7f6, +0xb04..+0xb84), transcribed 020
  asm elsewhere.
- -m68020 required; fixup.py splices original HUNK framing ->
  BYTE-IDENTICAL (md5 d17bbb8c808cbde4af634a33768657bf).
- work/oracle.py: fake Exec (AllocMem/FreeMem/Remove/CopyMem/
  AddHead etc.) + lib scan of the word-offset functab; exercised
  entry, init, all 10 vectors, chained pack, unpack round-trip,
  free vectors, -17/-2 error paths, deferred+real expunge.
- Original vs rebuild traces: RUNTIME-IDENTICAL (diff clean).
