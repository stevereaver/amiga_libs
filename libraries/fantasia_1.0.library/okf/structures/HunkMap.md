---
type: Structure
title: Hunk map
description: Binary layout of fantasia_1.0.library (804 bytes).
timestamp: 2026-10-10T18:00:00Z
---

# Hunk map

One code hunk (0x290 bytes), `HUNK_RELOC32` with 0x18 relocs
(includes absolute `jmp` targets inside JoyButtons), `HUNK_END`.

## .text layout

| offset | contents |
|-------:|----------|
| 0x00 | `moveq #0,d0 / rts` — entry returns 0, not -1 |
| 0x04 | RomTag, EndSkip→0x52 (**= InitTable, mid-module**), flags 0x80, v1 |
| 0x1e | `"fantasia.library"` |
| 0x2f | `"fantasia.library 1.0\n"` |
| 0x46 | `"dos.library"` |
| 0x52 | InitTable: dataSize 0x30, functab→0x62, datatable→0x7c, init→0x9a |
| 0x62 | function table: 6 × `dc.l` + `dc.l -1` |
| 0x7c | InitStruct data → 0x9a (starts with a00c quirk) |
| 0x9a | LibInit |
| 0xba-ish | LibOpen / LibClose / LibExpunge / reserved stub |
| 0x138 | JoyDir (JOY1DAT decode → d3) |
| 0x20c | JoyButtons (CIAA/POTGOR decode → d2) |
| 0x290 | hunk end |
