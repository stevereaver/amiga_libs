---
type: Structure
title: XpkInfo
description: Packer descriptor returned by XpksPackerInfo (0x58 bytes at .text+0x13c).
resource: source/xpkNONE_lib.s
timestamp: 2026-10-10T09:20:00Z
---

# XpkInfo

Static descriptor at .text+0x13c in the original (target of the `lea`
in [XpksPackerInfo](../functions/XpksPackerInfo.md)). Field layout per
`xpk/xpksub.h` in the Aminet `xpk_Develop` archive; every pointer field
is RELOC32-patched.

| off | field | value |
|----:|-------|-------|
| 0x00 | xi_XpkInfoVersion | 1 |
| 0x02 | xi_LibVersion | 1 |
| 0x04 | xi_MasterVersion | 2 |
| 0x06 | xi_ModesVersion | 0 |
| 0x08 | xi_Name | "NoPacker" (.text+0x1be) |
| 0x0c | xi_LongName | "NoPacker" (same pointer) |
| 0x10 | xi_Description | "A dummy library that does no compression" (.text+0x1c7 — the pointer skips a pad byte) |
| 0x14 | xi_ID | 0x4e4f4e45 `'NONE'` |
| 0x18 | xi_Flags | 9 = `XPKIF_PK_CHUNK`(1) \| `XPKIF_UP_CHUNK`(8) |
| 0x1c | xi_MaxPkInChunk | 0x8000 (32K) |
| 0x20 | xi_MinPkInChunk | 0x14 (20) |
| 0x24 | xi_DefPkInChunk | 0x8000 (32K) |
| 0x28 | xi_PackMsg | "Writing" (.text+0x1f0) |
| 0x2c | xi_UnpackMsg | "Reading" (.text+0x1f8) |
| 0x30 | xi_PackedMsg | "Wrote" (.text+0x200) |
| 0x34 | xi_UnpackedMsg | "Read" (.text+0x206) |
| 0x38 | xi_DefMode | 0x64 (100) |
| 0x3a | xi_Pad | 0 |
| 0x3c | xi_ModeDesc | [XpkMode](XpkMode.md) @ .text+0x194 |
| 0x40 | xi_Reserved[6] | all zero |

Differences from the 1.4 descriptor: `xi_XpkInfoVersion` is 1 (was 0),
`xi_MasterVersion` is 2 (was 1), `xi_DefMode` is 100 (was 50), and
`xi_Name`/`xi_LongName` both point at "NoPacker" — no separate "NONE"
name string exists.
