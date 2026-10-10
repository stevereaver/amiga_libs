---
type: Structure
title: XpkInfo / XpkMode
description: Descriptor values (static, hunk+0x2ae/0x306).
---

# XpkInfo / XpkMode

XpkInfo at hunk+0x2ae (88 B):

| field | V1.2 | V1.1 (for contrast) |
|---|---|---|
| xi_XpkInfoVersion / xi_LibVersion | 1 / 1 | 1 / 1 |
| xi_MasterVersion / xi_ModesVersion | 2 / 0 | 2 / 0 |
| xi_Name / xi_ID | "FastRLE" / 'FRLE' | "FRLE" / 'FRLE' |
| xi_LongName | "Fast Run Length Encoder V1.2" | "... 1.0" |
| xi_Description | "Optimized RLE for 68000" | "Cache-optimized RLE" |
| xi_Flags | 9 = PK_CHUNK\|UP_CHUNK | 9 |
| xi_MaxPkInChunk | 0x7fffffff | 0x20000 |
| xi_MinPkInChunk | 0 | 16 |
| xi_DefPkInChunk | 0x8000 | 0x8000 |
| xi_PackMsg / UnpackMsg / Packed / Unpacked | NULL x4 | strings |
| xi_DefMode | 100 | 16 |
| xi_ModeDesc | -> XpkMode hunk+0x306 | embedded |

XpkMode at hunk+0x306 (42 B): xm_Next 0, xm_Upto 100,
xm_Flags 1 (A3000SPEED), Pack/UnpackMemory 0,
xm_PackSpeed 370, xm_UnpackSpeed 1150, xm_Ratio 48 (48.0%),
xm_ChunkSize 0, xm_Description "normal".

String table at hunk+0x330: "FastRLE", "Fast Run Length
Encoder V1.2", "Optimized RLE for 68000".  The hunk ends at
0x370 with the unterminated tag "EVE" (0x36d-0x36f) -- an
easter egg, unreferenced by any descriptor field.