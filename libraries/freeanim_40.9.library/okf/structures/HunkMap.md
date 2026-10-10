---
type: Structure
title: Hunk map
description: Binary layout of freeanim_40.9.library (396 bytes).
timestamp: 2026-10-10T18:00:00Z
---

# Hunk map

One code hunk.  `HUNK_HEADER` (1 hunk), `HUNK_CODE` at 0x1c
(0x4c longwords = 0x130 bytes), `HUNK_RELOC32` with 0x10 relocs,
`HUNK_END`.

## .text layout

| offset | contents |
|-------:|----------|
| 0x00 | `moveq #-1,d0 / rts` |
| 0x04 | RomTag `4afc`, EndSkip→0x130 (hunk end), flags 0x81 (AUTOINIT\|COLDSTART), v40, NT_LIBRARY, pri 0 |
| 0x1e | `"freeanim.library"` |
| 0x2f | `"freeanim.library 40.9 (11.8.95)\r\n"` (no `$VER:`) |
| 0x51 | stray bytes `4e 71` (NOP at odd address) + `00` pad |
| 0x54 | InitTable: dataSize 0x26, functab→0x64, datatable→0x70, init→0x128 |
| 0x64 | function table: `-1`, `008c 0094 0030 002c`, `-1` |
| 0x70 | InitStruct data → 0x8e; stray NOP at 0x8e |
| 0x90 | ExtFunc stub `moveq #0,rts` |
| 0x94 | LibExpunge |
| 0xf0 | LibOpen |
| 0xf8 | LibClose |
| 0x128 | LibInit |
| 0x12e | `rts`; hunk ends 0x130 |
