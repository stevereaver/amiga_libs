---
type: Structure
title: HunkMap
description: Byte map of the single code hunk (0xc0 bytes).
---

# HunkMap — version_40.43.library

Single HUNK_CODE section, 0xc0 bytes; 7 RELOC32 fixups (RomTag
pointers + InitTable pointers only).

| offset | content |
|-------:|---------|
| 0x00 | `moveq #-1,d0` / `rts` executable entry |
| 0x04 | RomTag (RTF_AUTOINIT, ver 40, NT_LIBRARY, pri 0) |
| 0x1e | `"version.library"` NUL |
| 0x2e | `"version 40.43 (07.2.11)\r\n"` NUL |
| 0x48 | InitTable: dataSize=0x2a, functab=0x58, data=0, init=0x64 |
| 0x58 | function table: -1, 0x20, 0x28, 0x62, 0x62, -1 |
| 0x64 | LibInit |
| 0x78 | LibOpen |
| 0x80 | LibClose (with inline unlink + FreeMem) |
| 0xba | LibNull stub (Expunge + ExtFunc target) |
| 0xbe | pad word 0x0000; RT_ENDSKIP points here (0xbe) |
