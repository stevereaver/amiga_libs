---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-02-20
- Word-offset functab (4 vectors); real DELEXP lifecycle.
- `source/version.s` byte-exact rebuild; md5 `51f78258bcde8be428f3131c250b7aeb`.
- machine68k oracle: init/open/close/expunge/deferred-expunge/stub
  all trace-identical (RUNTIME IDENTICAL).

## 2026-10-10
- Parsed 308-byte single-CODE-hunk module: entry `moveq #-1,d0/
  rts`, RomTag (AUTOINIT, ver 47, NT_LIBRARY), name
  `version.library`, id `version 47.2 (10.4.2021)`.
- InitTable @mem 0x4a: dataSize 0x2a, word-offset functab
  (-1 … -1), no InitStruct, initFunc @mem 0x66 writing
  lib_Revision = 2.
- Vectors: Open (opencnt++, clear DELEXP), Close (opencnt--,
  expunge at 0 && DELEXP), Expunge (mark DELEXP while open else
  expunge: inlined Remove + FreeMem + seglist), ExtFunc null stub.
- Noted: 47.x returns to textbook DELEXP semantics — unlike the
  39/40.x unconditional-Close-expunge quirk and without the
  44.x/45.x extended base + hidden semaphore probe.
- Reconstructed C + asm header; `make` builds `version.library`;
  IRA re-disassembly confirms equivalent vector logic.
