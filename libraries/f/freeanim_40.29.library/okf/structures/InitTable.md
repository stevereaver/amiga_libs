---
type: Structure
title: InitTable
description: RomTag and InitTable fields.
timestamp: 2026-10-10T18:00:00Z
---

# InitTable / RomTag

RomTag at code+0x04:

| field | value |
|-------|-------|
| RT_MATCHWORD | 0x4afc |
| RT_MATCHTAG  | 0x04 (self) |
| RT_ENDSKIP   | 0x6a — last word of the hunk (pad), mid-module |
| RT_FLAGS     | 0x80 — RTF_AUTOINIT only |
| RT_VERSION   | 40 |
| RT_TYPE      | 9 — NT_LIBRARY |
| RT_PRI       | 0 |
| RT_NAME      | "freeanim.library" |
| RT_IDSTRING  | "freeanim 40.29 (1.4.94)\r\n" |
| RT_INIT      | InitTable at code+0x4a |

InitTable (code+0x4a): dataSize = 0x2a, funcTable = 0x5a,
dataTable = NULL (no InitStruct), initFunc = 0x66 (the shared
`moveq #0,rts` — returns 0, i.e. init failure by MakeLibrary
convention).

Function table (word offsets from table start): `-1`, then four
entries `0x000c` (all → 0x66), then `-1`.
