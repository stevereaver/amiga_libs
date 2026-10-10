---
type: Structure
title: XpkInfo / XpkMode
description: Static packer descriptor returned by XpksPackerInfo.
timestamp: 2026-10-10T22:45:00Z
---

# XpkInfo / XpkMode

Embedded at hunk +0x66 (XpkInfo, 88 bytes) and +0xbe (XpkMode,
42 bytes):

| field | value |
|---|---|
| xi_XpkInfoVersion / xi_LibVersion | 1 / 1 |
| xi_MasterVersion / xi_ModesVersion | 2 / 0 |
| xi_Name / xi_ID | "FRLE" / 'FRLE' |
| xi_LongName | "Fast Run Length Encoder 1.0" |
| xi_Description | "Cache-optimized RLE" |
| xi_Flags | 9 = XPKIF_PK_CHUNK \| XPKIF_UP_CHUNK |
| xi_MaxPkInChunk / Min / Def | 131072 / 16 / 32768 |
| xi_PackMsg etc. | "Packing"/"Unpacking"/"Packed"/"Unpacked" |
| xi_DefMode | 16 |
| xm_Description | "ByteRun" |
| xm_Upto / xm_Flags | 100 / XPKMF_A3000SPEED |
| xm_PackSpeed / xm_UnpackSpeed | 800 / 1480 |
| xm_Ratio | 2 (advertised 2.0%!) |
| xm_PackMemory / xm_UnpackMemory / xm_ChunkSize | 0 |

The 2% ratio claim is marketing; typical output is near or above
the input size on incompressible data (no expansion bail-out).
