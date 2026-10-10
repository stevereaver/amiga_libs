---
type: Structure
title: Hunk map
description: Binary layout of boards_1.0.library (592 bytes).
timestamp: 2026-10-10T18:00:00Z
---

# Hunk map

One code hunk.  `HUNK_HEADER` (1 hunk), `HUNK_CODE` at 0x1c
(0x80 longwords = 0x200 bytes), `HUNK_RELOC32` with 0x11 relocs,
`HUNK_END`.

## .text layout

| offset | contents |
|-------:|----------|
| 0x00 | `moveq #-1,d0 / rts` |
| 0x04 | RomTag, EndSkip→0x200, flags 0x80, v1, NT_LIBRARY |
| 0x1e | `"boards.library"` |
| 0x2d | `"boards.library 1.0 (14.4.96)\r\n"` |
| 0x4e | copyright string (Körber / "Replaces boards.library by Torsten Bach") |
| 0xd0 | InitTable: dataSize 0x2c, functab→0xe0, datatable→0xf8, init→0x118 |
| 0xe0 | function table: 5 × `dc.l` absolute + `dc.l -1` |
| 0xf8 | InitStruct data → 0x116 |
| 0x118 | LibInit |
| 0x152 | `"expname.library"` |
| 0x162 | LibOpen / 0x170 LibClose / 0x184 LibExpunge |
| 0x1de | reserved stub / 0x1e2 BoardsFunc |
| 0x1f6 | code cell: libbase (dead store) |
| 0x1fa | code cell: expname base |
| 0x1fe | NOP; hunk ends 0x200 |
