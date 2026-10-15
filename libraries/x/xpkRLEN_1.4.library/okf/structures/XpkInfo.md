---
type: Structure
title: XpkInfo
description: Packer descriptor returned by XpksPackerInfo (0x58 bytes at .text+0x21e).
resource: source/xpkRLEN_lib.s
timestamp: 2026-10-10T09:40:00Z
---

# XpkInfo

Static descriptor at .text+0x21e (target of the `lea` in
[XpksPackerInfo](../functions/XpksPackerInfo.md)).

| off | field | value |
|----:|-------|-------|
| 0x00 | xi_XpkInfoVersion | 1 |
| 0x02 | xi_LibVersion | 1 |
| 0x04 | xi_MasterVersion | **0** — see [MasterVersionZero](../findings/MasterVersionZero.md) |
| 0x06 | xi_ModesVersion | 0 |
| 0x08 | xi_Name | "RLEN" (.text+0x90) |
| 0x0c | xi_LongName | "Run Length" (.text+0x95 — skips a pad byte) |
| 0x10 | xi_Description | "Fast and simple compression usable for simple data" (.text+0xa0) |
| 0x14 | xi_ID | 0x524c454e `'RLEN'` |
| 0x18 | xi_Flags | 9 = `XPKIF_PK_CHUNK`(1) \| `XPKIF_UP_CHUNK`(8) |
| 0x1c | xi_MaxPkInChunk | 0x7fffffff |
| 0x20 | xi_MinPkInChunk | 0 |
| 0x24 | xi_DefPkInChunk | 0x4004 — see [DefPkInChunk4004](../findings/DefPkInChunk4004.md) |
| 0x28 | xi_PackMsg | NULL |
| 0x2c | xi_UnpackMsg | NULL |
| 0x30 | xi_PackedMsg | NULL |
| 0x34 | xi_UnpackedMsg | NULL |
| 0x38 | xi_DefMode | 0x32 (50) |
| 0x3a | xi_Pad | 0 |
| 0x3c | xi_ModeDesc | [XpkMode](XpkMode.md) @ .text+0x1f4 |
| 0x40 | xi_Reserved[6] | all zero |
