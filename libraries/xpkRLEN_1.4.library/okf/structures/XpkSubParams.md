---
type: Structure
title: XpkSubParams
description: Chunk I/O parameter block for Pack/Unpack calls (ABI).
resource: source/xpkRLEN.c
timestamp: 2026-10-10T09:40:00Z
---

# XpkSubParams

Parameter block (a0) for [XpksPackChunk](../functions/XpksPackChunk.md)
and [XpksUnpackChunk](../functions/XpksUnpackChunk.md). Full ABI per
`xpk/xpksub.h`; the fields this sublibrary touches:

| off | field | notes |
|----:|-------|-------|
| 0x00 | xsp_InBuf | input data (pack source / packed stream) |
| 0x04 | xsp_InLen | input length |
| 0x08 | xsp_OutBuf | output buffer |
| 0x0c | xsp_OutBufLen | capacity — checked by Pack, **ignored** by Unpack |
| 0x10 | xsp_OutLen | written by Pack only (= produced bytes) |
| 0x14..0x43 | xsp_Flags/Number/Mode/Password/LibVersion/Arg/Sub | untouched |
