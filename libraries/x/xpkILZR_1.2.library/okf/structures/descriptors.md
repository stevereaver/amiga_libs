---
type: Structure
title: xpkILZR 1.2 descriptors
---

# Descriptors — descblock (192 B, copied to base+0x3c)

Hunk source: code+0xea .. code+0x1a9.

## XpkInfo at block+0x62 (→ base+0x9e, PackerInfo target)

| off | value | field |
|-----|-------|-------|
| +0  | 1,0,0,0 | XpkInfo/Lib/Master/Modes versions |
| +8  | →"ILZR" @ code+0x63 | xi_Name |
| +12 | →"Incremental Lempel Ziv Renau" @0x68 | xi_LongName |
| +16 | →"A very fast low memory compression, fast hash version of LZSS" @0x85 | xi_Description |
| +20 | 'ILZR' | xi_ID |
| +24 | 0x8009 | xi_Flags (XPKEF_AVAIL?) |
| +28 | 0x4000 | xi_MaxPkInChunk |
| +32 | 0 | xi_MinPkInChunk |
| +36 | 0x4000 | xi_DefPkInChunk |
| +40 | →"Compressing" @0xc3 | xi_PackMsg |
| +44 | →"Expanding" @0xcf | xi_UnpackMsg |
| +48 | →"Packed" @0xd9 | xi_PackedMsg |
| +52 | →"unpacked" @0xe0 | xi_UnpackedMsg |
| +56 | 50 | xi_DefMode |
| +60 | **0x38** | xi_ModeDesc — BLOCK-RELATIVE offset, |
|     |          | never relocated (dead Open fixup)   |
| +64 | 0×24 | reserved |

## XpkMode record at block+0x38 (what 0x38 points at)

| field | value |
|-------|-------|
| next | 0 |
| upto | 100 |
| flags | 1 |
| packmem | 0 |
| unpackmem | 0 |
| packspeed | 200 |
| unpackspeed | 300 |
| ratio | 0x028f = 655 |
| chunksize | 0 |
| desc[10] | "Fast" |

## Block tail

- block+0xba..+0xbf: `00 00 00 00 10 00`; the long at
  +0xbc = **0x1000** = suballoc minsize (base+0xf8)

## $VER string at block+0x04

`$VER: xpkIZLR.library 1.2 (Feb 19 1994) Jose Renau` —
note the transposed "IZLR" (shipped typo); the separate
rt_IdString "xpkILZR v1.3" is correct but claims v1.3.
