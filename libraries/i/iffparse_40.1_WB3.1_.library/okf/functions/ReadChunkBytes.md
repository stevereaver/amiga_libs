---
type: Function
title: ReadChunkBytes
description: Reads from stream into buf, clamped to the current chunk's remaining bytes.
lvo: -60
registers: a0,a1,d0
timestamp: 2026-10-10T18:00:00Z
---

# `LONG ReadChunkBytes(iff,buf,numBytes)`

**LVO -60** — registers `a0,a1,d0`

Reads from stream into buf, clamped to the current chunk's remaining bytes; updates cn_Scan.
