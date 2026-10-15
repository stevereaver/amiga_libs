---
type: Structure
title: XpkSubParams
description: Chunk I/O parameter block for Pack/Unpack calls (ABI).
resource: source/xpkNONE.c
timestamp: 2026-10-10T09:20:00Z
---

# XpkSubParams

Parameter block (a0) for [XpksPackChunk](../functions/XpksPackChunk.md)
and [XpksUnpackChunk](../functions/XpksUnpackChunk.md). Full ABI per
`xpk/xpksub.h`; this sublibrary only touches the first five fields:

| off | field | notes |
|----:|-------|-------|
| 0x00 | xsp_InBuf | input data |
| 0x04 | xsp_InLen | input length |
| 0x08 | xsp_OutBuf | output buffer |
| 0x0c | xsp_OutBufLen | output buffer capacity (unchecked here) |
| 0x10 | xsp_OutLen | bytes written (set = InLen by UnpackChunk) |
| 0x14 | xsp_Flags | master/sub comm. flags (unused) |
| 0x18 | xsp_Number | chunk number (unused) |
| 0x1c | xsp_Mode | packing mode (unused) |
| 0x20 | xsp_Password | (unused) |
| 0x24 | xsp_LibVersion | sublib version used to pack (unused) |
| 0x26 | xsp_Pad | |
| 0x28 | xsp_Arg[3] | |
| 0x34 | xsp_Sub[4] | sublib private data |
