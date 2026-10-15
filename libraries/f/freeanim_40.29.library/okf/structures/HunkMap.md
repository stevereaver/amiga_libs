---
type: Structure
title: Hunk map
description: Binary layout of freeanim_40.29.library (188 bytes).
timestamp: 2026-10-10T18:00:00Z
---

# Hunk map

One code hunk only.  Hunk header at 0x00 (`HUNK_HEADER`, 1 hunk),
`HUNK_CODE` at 0x1c (0x1b longwords = 0x6c bytes), `HUNK_RELOC32`
with 7 entries, `HUNK_END` at file+0xb6.

## .text layout

| offset | contents |
|-------:|----------|
| 0x00 | `moveq #-1,d0 / rts` (executable-entry return) |
| 0x04 | RomTag `4afc`, MatchTag→0x04, EndSkip→0x6a (the pad word), flags 0x80 AUTOINIT, version 40, NT_LIBRARY, pri 0 |
| 0x1e | `"freeanim.library"` |
| 0x2f | `"freeanim 40.29 (1.4.94)\r\n"` (no `$VER:`) |
| 0x4a | InitTable: dataSize 0x2a, functab→0x5a, dataTable=0, initFunc→0x66 |
| 0x5a | function table: `dc.w -1`, 4 × `0x000c`, `dc.w -1` |
| 0x66 | `moveq #0,d0 / rts` — shared Open/Close/Expunge/ExtFunc/init stub |
| 0x6a | pad word (EndSkip target); hunk ends at 0x6c |

Relocatable longwords at code offsets 0x06,0x0a,0x12,0x16,0x1a
(RomTag) and 0x4e (funcTable), 0x56 (initFunc).
