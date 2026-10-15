---
type: Structure
title: XpkInfo
description: Packer descriptor returned by XpksPackerInfo (0x58 bytes at code+0x15a).
---

# XpkInfo

Static island; every pointer field is RELOC32-patched.  Field layout
per `xpk/xpksub.h`; observed values:

| off | field | value |
|----:|-------|-------|
| 0x00 | xi_XpkInfoVersion | 1 |
| 0x02 | xi_LibVersion | 0 |
| 0x04 | xi_MasterVersion | 2 |
| 0x06 | xi_ModesVersion | 0 |
| 0x08 | xi_Name | "Delta" |
| 0x0c | xi_LongName | "Delta Encryptor V0.3" |
| 0x10 | xi_Description | "DELTA-Encryption Routines (C) 1992 Stephan Fuhrmann" |
| 0x14 | xi_ID | `'DLTA'` |
| 0x18 | xi_Flags | 0x2009 = PK_CHUNK(1) \| UP_CHUNK(8) \| ENCRYPTION(0x2000) |
| 0x1c | xi_MaxPkInChunk | 0x10000 (64K) |
| 0x20 | xi_MinPkInChunk | 0 |
| 0x24 | xi_DefPkInChunk | 0x10000 |
| 0x28 | xi_PackMsg | "Enciphering" |
| 0x2c | xi_UnpackMsg | "Deciphering" |
| 0x30 | xi_PackedMsg | "Enciphered" |
| 0x34 | xi_UnpackedMsg | "Deciphered" |
| 0x38 | xi_DefMode | 100 |
| 0x3a | xi_Pad | 0 |
| 0x3c | xi_ModeDesc | [XpkMode](XpkMode.md) @ code+0x1b2 |
| 0x40 | xi_Reserved[6] | all zero |
