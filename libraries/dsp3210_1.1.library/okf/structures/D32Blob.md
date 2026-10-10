---
type: Structure
title: D32Blob
description: The d32 object/"blob" file format decoded from the loader.
resource: source/dspbase.h
timestamp: 2026-10-10T20:10:00Z
---

# D32 blob format

All fields big-endian (native reads on m68k; the original assembles
some byte-wise — same result). Blobs are produced by the AT&T "d32"
tools (d32as/d32cc).

## Header

| off | field | notes |
|----:|-------|-------|
| 0x00 | u16 magic | 0x0166 |
| 0x02 | u16 nsec | section count |
| 0x08 | u32 symtabOff | symbol table offset from blob start |
| 0x0c | u32 symCount | symbol count (18-byte entries) |
| 0x10 | u16 sectOff | section table offset **relative to blob+20** |

String table immediately follows the symbol table
(`symtabOff + symCount*18`, where the multiply is 16-bit).

## Section record (40 bytes)

| off | field | notes |
|----:|-------|-------|
| +12 | u32 linkedBase | address the section was linked at |
| +16 | u32 size | section data size |
| +20 | u32 dataOff | offset of section data in blob |
| +24 | u32 relocOff | offset of reloc records |
| +30 | u32 relocCount | number of reloc records |
| +36 | u32 flags | loadable iff exactly 0x20, 0x40 or 0x80 |

## Symbol entry (18 bytes)

| off | field | notes |
|----:|-------|-------|
| +0 | u8 flag/inline name | nonzero → NUL-terminated inline name at +0 |
| +6 | u16 strOff | string-table offset for the name (if +0 == 0) |
| +8 | u32 value | symbol value (linked address) |
| +12 | s16 sect | defining section, 1-based; 0 = external, <0 = bad |

## Reloc record (16 bytes)

| off | field | notes |
|----:|-------|-------|
| +0 | u32 offset | patch offset within the target section |
| +4 | u32 symIdx | symbol index, ×18 into the symtab |
| +8 | u16 type | 0x1c/0x2c/0x2e/0x2f — see [DSPRelocate](../functions/DSPRelocate.md) |
| +10 | pad | 6 bytes unused |
