---
type: Structure
title: XpkInfo
description: Packer descriptor returned by XpksPackerInfo (0x58 bytes at .text+0x1ae).
resource: source/xpkbase.h
timestamp: 2026-10-10T19:45:00Z
---

# XpkInfo

Static descriptor at .text+0x1ae in the original (target of the `lea`
in [XpksPackerInfo](../functions/XpksPackerInfo.md)). Field layout per
`xpk/xpksub.h` in the Aminet `xpk_Develop` archive; every pointer field
is RELOC32-patched in the binary.

| off | field | value |
|----:|-------|-------|
| 0x00 | xi_XpkInfoVersion | 0 |
| 0x02 | xi_LibVersion | 1 |
| 0x04 | xi_MasterVersion | 1 |
| 0x06 | xi_ModesVersion | 0 |
| 0x08 | xi_Name | "NONE" (.text+0x206) |
| 0x0c | xi_LongName | "NoPacker" (.text+0x20c) |
| 0x10 | xi_Description | "A dummy library that does no compression" (.text+0x216) |
| 0x14 | xi_ID | 0x4e4f4e45 `'NONE'` |
| 0x18 | xi_Flags | 9 = `XPKIF_PK_CHUNK`(1) \| `XPKIF_UP_CHUNK`(8) |
| 0x1c | xi_MaxPkInChunk | 0x8000 (32K) |
| 0x20 | xi_MinPkInChunk | 0x14 (20) |
| 0x24 | xi_DefPkInChunk | 0x8000 (32K) |
| 0x28 | xi_PackMsg | "Writing" |
| 0x2c | xi_UnpackMsg | "Reading" |
| 0x30 | xi_PackedMsg | "Wrote" |
| 0x34 | xi_UnpackedMsg | "Read" |
| 0x38 | xi_DefMode | 0x32 (50) |
| 0x3a | xi_Pad | 0 |
| 0x3c | xi_ModeDesc | [XpkMode](XpkMode.md) @ .text+0x184 |
| 0x40 | xi_Reserved[6] | all zero |

`xi_XpkInfoVersion` = 0 — the field documenting the struct format
version is zero in this 1998 build (see
[XpkInfoVersionZero](../findings/XpkInfoVersionZero.md)).
