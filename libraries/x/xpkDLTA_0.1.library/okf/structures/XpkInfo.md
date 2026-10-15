---
type: Structure
title: XpkInfo / XpkMode
description: Descriptor values (InitStruct-written).
---

# XpkInfo / XpkMode

XpkInfo at base+0x26 (88 B):

| field | value |
|---|---|
| xi_XpkInfoVersion / xi_LibVersion | 1 / 0 (v0.1!) |
| xi_MasterVersion / xi_ModesVersion | 1 / 0 |
| xi_Name / xi_ID | "DLTA" / 'DLTA' |
| xi_LongName | "DELTA v0.1" |
| xi_Description | "DELTA-Encryption Routines (c) 1992 Stephan Fuhrmann" |
| xi_Flags | 0x2000 |
| xi_MaxPkInChunk / Min / Def | 0x10000 / 1 / 0x10000 |
| xi_PackMsg etc. | "Enciphering"/"Deciphering"/"Enciphered"/"Deciphered" |
| xi_DefMode | 100 |
| xi_ModeDesc | base+0x7e (patched by LibInit) |

XpkMode at base+0x7e (42 B): Upto=100 via InitStruct,
Description "ByteMode" written as two literal longs
('Byte','Mode') at base+0x9e/0xa2; speeds/memory fields
all 0.

xi_Flags 0x2000 is outside the usual XPKIF_PK_CHUNK/
UP_CHUNK bit positions — presumably a "byte-mode" or
encryption flag from an early sublib API revision.
