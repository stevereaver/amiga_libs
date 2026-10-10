---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-10
- Parsed 308-byte single-CODE-hunk module — byte-layout identical
  to version.library 47.2 except idstring `version 47.3
  (13.7.2021)` and init immediate `lib_Revision = 3`.
- Same InitTable (dataSize 0x2a), same functab offsets
  (+0x20/+0x2e/+0x40/+0x84), same textbook DELEXP vectors.
- Incident: an `ira source target` typo overwrote the binary;
  restored byte-for-byte from a hexdump captured just before
  (sha256 verified: 7b2f66e8…).  Lesson recorded: always pass a
  `work/` path as the IRA target.
- Reconstructed C + asm header (shared shape with 47.2);
  `make` builds `version.library`; IRA re-disassembly confirms
  equivalent vector logic and revision-3 stamp.
