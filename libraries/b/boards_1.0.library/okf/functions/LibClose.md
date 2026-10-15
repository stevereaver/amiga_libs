---
type: Function
title: LibClose
description: OpenCnt--; on 0 + private flag bit0 calls expunge.
lvo: -12
registers: a6 = library base
timestamp: 2026-10-10T18:00:00Z
---

# `ULONG LibClose(void)`

**LVO -12** (code+0x170) — registers `a6 = libbase`

`moveq #0,d0; subq.w #1,32(a6); bne rts; btst #0,35(a6); beq rts;
bsr Expunge; rts`.
