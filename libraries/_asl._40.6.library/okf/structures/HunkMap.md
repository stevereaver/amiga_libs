---
type: Structure
title: Hunk map
description: Binary layout of _asl._40.6.library (452 bytes).
timestamp: 2026-10-10T18:00:00Z
---

# Hunk map

One code hunk.  `HUNK_HEADER` (1 hunk), `HUNK_CODE` at 0x1c
(0x59 longwords = 0x164 bytes), `HUNK_RELOC32` with 0x0b relocs,
`HUNK_END`.

## .text layout

| offset | contents |
|-------:|----------|
| 0x00 | `moveq #-1,d0 / rts` |
| 0x04 | RomTag `4afc`, EndSkip→0x164, flags 0x80 AUTOINIT, v40, NT_LIBRARY, pri 0 |
| 0x1e | `"_asl.library"` (byte +1 → `"asl.library"`) |
| 0x2b | `"$VER: _asl.library 40.6"` |
| 0x44 | InitTable: dataSize 0x2e, functab→0x54, datatable→0x6e, init→0x94 |
| 0x54 | function table: `-1`, ten word offsets, `-1`, pad `-1` |
| 0x6e | InitStruct data → 0x94 |
| 0x94 | LibInit (stores seglist @ +0x2a) |
| 0xa4 | LibOpen |
| 0xb4 | LibClose |
| 0xca | LibExpunge |
| 0x108 | ExtFunc stub `moveq #0,rts` |
| 0x10c-0x121 | six relay stubs (`moveq #-30..-60,d1; bra relay`) |
| 0x122 | relay tail (open real asl.library, jsr LVO, close) |
| 0x162 | ENDSKIP `bra` back into tail; hunk ends 0x164 |
