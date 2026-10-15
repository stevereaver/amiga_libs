---
type: Structure
title: XpkInfo
description: Packer descriptor embedded in the library base at +0x26.
---

# XpkInfo (base+0x26)

Built by the InitStruct data table at library initialisation; string
pointer cells are RELOC32-patched in the table, values point into the
code hunk.  Observed values:

| off | field | value |
|----:|-------|-------|
| 0x00 | xi_XpkInfoVersion | 1 |
| 0x02 | xi_LibVersion | 0 |
| 0x04 | xi_MasterVersion | 1 |
| 0x06 | xi_ModesVersion | 0 |
| 0x08 | xi_Name | "DLTA" |
| 0x0c | xi_LongName | "DELTA v0.2" |
| 0x10 | xi_Description | "DELTA-Encryption Routines (C) 1992 Stephan Fuhrmann" |
| 0x14 | xi_ID | `'DLTA'` |
| 0x18 | xi_Flags | 0x2000 = ENCRYPTION only (PK/UP_CHUNK missing!) |
| 0x1c | xi_MaxPkInChunk | 0x10000 (64K) |
| 0x20 | xi_MinPkInChunk | 1 |
| 0x24 | xi_DefPkInChunk | 0x10000 |
| 0x28 | xi_PackMsg | "Enciphering" |
| 0x2c | xi_UnpackMsg | "Deciphering" |
| 0x30 | xi_PackedMsg | "Enciphered" |
| 0x34 | xi_UnpackedMsg | "Deciphered" |
| 0x38 | xi_DefMode | 100 |
| 0x3a | xi_Pad | 0 |
| 0x3c | xi_ModeDesc | base+0x7e ([XpkMode](XpkMode.md)) — linked by LibInit |
| 0x40 | xi_Reserved[6] | zero |
