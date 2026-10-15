---
type: Structure
title: XpkInfo / XpkMode
description: Descriptor values written by LibInit.
---

# XpkInfo / XpkMode (runtime-initialised)

XpkInfo at base+0x28 (88 B):

| field | value |
|---|---|
| xi_XpkInfoVersion / xi_LibVersion | 1 / 1 |
| xi_MasterVersion / xi_ModesVersion | 1 / 0 |
| xi_Name / xi_ID | "CBR0" / 'CBR0' |
| xi_LongName | "Cmp Byte Run 0 Packer v1.1" |
| xi_Description | "fast and simple compression of data containing many repeating equal bytes" |
| xi_Flags | 9 = XPKIF_PK_CHUNK \| XPKIF_UP_CHUNK |
| xi_MaxPkInChunk / Min / Def | 0xfffc / 0 / 0xfffc |
| xi_PackMsg etc. | "Compressing"/"Decompressing"/"Compressed"/"Decompressed" |
| xi_DefMode | 50 |

XpkMode at base+0x80 (42 B):

| field | value |
|---|---|
| xm_Upto / xm_Flags | 100 / 1 (XPKMF_A3000SPEED) |
| xm_PackSpeed / xm_UnpackSpeed | 410 / 1918 |
| xm_Ratio | 31 |
| xm_ChunkSize | 63 (odd shipped value) |
| xm_PackMemory / xm_UnpackMemory | 0 |
| xm_Description | "normal" (last 2 bytes left zeroed) |
