---
type: Structure
title: HunkMap
description: Byte map of the single code hunk (0x10c bytes).
---

# HunkMap — version_44.2(WB3.5).library

Single HUNK_CODE section, 0x10c bytes; 7 RELOC32 fixups (RomTag
pointers + InitTable pointers only — the probe address is stored
via pc-relative `lea`).

| offset | content |
|-------:|---------|
| 0x00 | `moveq #-1,d0` / `rts` executable entry |
| 0x04 | RomTag (RTF_AUTOINIT, ver 44, NT_LIBRARY, pri 0) |
| 0x1e | `"version.library"` NUL |
| 0x2e | `"version 44.2 (11.8.99)\r\n"` NUL + pad |
| 0x48 | InitTable: dataSize=0x36, functab=0x58, data=0, init=0x64 |
| 0x58 | function table: -1, 0x34, 0x3c, 0x76, 0x76, -1 |
| 0x64 | LibInit (extra stores: self, date, probe ptr) |
| 0x8c | LibOpen |
| 0x94 | LibClose (with inline unlink + FreeMem) |
| 0xce | LibNull stub (Expunge + ExtFunc target) |
| 0xd2 | hidden probe routine (FindSemaphore wrapper) |
| 0x100 | 10 obfuscated semaphore-name bytes |
| 0x10a | pad `0000`; RT_ENDSKIP = 0x10b (odd — inside the pad) |
