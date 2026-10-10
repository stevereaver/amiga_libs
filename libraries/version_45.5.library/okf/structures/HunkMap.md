---
type: Structure
title: HunkMap
description: Byte map of the single code hunk (0x110 bytes).
---

# HunkMap — version_45.5.library

Single HUNK_CODE section, 0x110 bytes; 7 RELOC32 fixups (RomTag
pointers + InitTable pointers only — the probe address is stored
via pc-relative `lea`).

| offset | content |
|-------:|---------|
| 0x00 | `moveq #-1,d0` / `rts` executable entry |
| 0x04 | RomTag (RTF_AUTOINIT, ver 45, NT_LIBRARY, pri 0) |
| 0x1e | `"version.library"` NUL |
| 0x2e | `"version 45.5 (25.4.2010)\r\n"` NUL + pad |
| 0x4a | InitTable: dataSize=0x36, functab=0x5a, data=0, init=0x66 |
| 0x5a | function table: -1, 0x34, 0x3c, 0x76, 0x76, -1 |
| 0x66 | LibInit (extra stores: self, date, probe ptr) |
| 0x8e | LibOpen |
| 0x96 | LibClose (with inline unlink + FreeMem) |
| 0xd0 | LibNull stub (Expunge + ExtFunc target) |
| 0xd4 | hidden probe routine (FindSemaphore wrapper) |
| 0x102 | 10 obfuscated semaphore-name bytes |
| 0x10c | pad `0000 0000`; RT_ENDSKIP = 0x10d (odd — inside the pad) |
