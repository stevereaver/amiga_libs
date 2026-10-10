---
type: Function
title: LibClose
description: OpenCnt--; on 0 + LIBF_DELEXP calls expunge; returns seglist or 0.
lvo: -12
registers: a6 = library base
timestamp: 2026-10-10T18:00:00Z
---

# `ULONG LibClose(void)`

**LVO -12** (code+0xb4) — registers `a6 = libbase`

`moveq #0,d0; subi.w #1,32(a6); bne rts; btst #3,14(a6); beq rts;
bsr Expunge; rts` — unguarded decrement (can underflow), conditional
expunge.
