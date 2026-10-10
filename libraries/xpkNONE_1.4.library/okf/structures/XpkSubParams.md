---
type: Structure
title: XpkSubParams
description: Chunk I/O parameter block for Pack/Unpack calls (ABI prefix).
resource: source/xpkbase.h
timestamp: 2026-10-10T19:45:00Z
---

# XpkSubParams

Parameter block (a0) for [XpksPackChunk](../functions/XpksPackChunk.md)
and [XpksUnpackChunk](../functions/XpksUnpackChunk.md). The full ABI
has more fields (flags, chunk number, mode, password, private area);
this sublibrary only touches the first five:

| off | field | notes |
|----:|-------|-------|
| 0x00 | xsp_InBuf | input data |
| 0x04 | xsp_InLen | input length |
| 0x08 | xsp_OutBuf | output buffer |
| 0x0c | xsp_OutBufLen | output buffer capacity (unchecked here) |
| 0x10 | xsp_OutLen | bytes written (set = InLen by UnpackChunk) |
