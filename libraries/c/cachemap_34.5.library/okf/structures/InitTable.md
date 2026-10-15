---
type: Structure
title: InitTable
description: RomTag, InitTable and word-offset function table.
timestamp: 2026-10-10T19:30:00Z
---

# InitTable / module header

- Entry `moveq #0,d0 / rts` (returns 0).
- RomTag @0x04: EndSkip = +0x39c (whole code hunk), flags 0x80,
  version 34, type 9, pri 0.  name "cachemap.library",
  id "CacheMap 34.5 (10.3.92)\r\n", init @0x1e.
- InitTable: `{dataSize=0x3c, funcTable=@0x2e, dataTable=0,
  initFunc=@0x4a}` — no InitStruct data.
- Function table: word offsets relative to table start, `-1W`
  marker and terminator; the -24 entry is the negative offset
  `0xffd2` back to the module entry.
- "graphics.library" string lives in the code hunk (PC-relative
  open at init).
