---
type: Structure
title: xpkILZR descriptors
---

# XpkInfo + XpkMode

Static data in the code hunk (XpksPackerInfo `lea`s it).

## XpkInfo (at hunk offset ~0x524)

| off | field | value |
|-----|-------|-------|
| +0  | xi_XpkInfoVersion (w) | 1 |
| +2  | xi_LibVersion (w) | 1 |
| +4  | xi_MasterVersion (w) | 2 |
| +6  | xi_ModesVersion (w) | 0 |
| +8  | xi_Name | "ILZR" |
| +12 | xi_LongName | "Incremental LZ-Renau V1.5" |
| +16 | xi_Description | "A very fast low memory compression, fast hash version of LZSS" |
| +20 | xi_ID | 'ILZR' |
| +24 | xi_Flags | 9 |
| +28 | xi_MaxPkInChunk | 0x4000 (16384) |
| +32 | xi_MinPkInChunk | 0 |
| +36 | xi_DefPkInChunk | 0x4000 |
| +40 | xi_PackMsg | "Compressing" |
| +44 | xi_UnpackMsg | "Expanding" |
| +48 | xi_PackedMsg | "Packed" |
| +52 | xi_UnpackedMsg | "Unpacked" |
| +56 | xi_DefMode (w) | 100 |
| +58 | pad (w) | 0 |
| +60 | xi_ModeDesc | -> XpkMode below |
| +64 | xi_Reserved[6] | 0 |

## XpkMode (single node)

| off | field | value |
|-----|-------|-------|
| +0  | next | 0 (end of list) |
| +4  | upto | 100 |
| +8  | flags | 1 |
| +12 | packmem | 0x18004 (matches the lazy AllocMem) |
| +16 | unpackmem | 0 |
| +20 | packspeed | 28 |
| +24 | unpackspeed | 260 |
| +28 | ratio (w) | 385 |
| +30 | chunksize (w) | 0 |
| +32 | desc[10] | "fast" |

A stray byte `k` sits after "Unpacked" in the original —
likely a linker pad byte; reproduced for byte fidelity.
