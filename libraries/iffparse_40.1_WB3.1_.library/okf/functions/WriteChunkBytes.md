---
type: Function
title: WriteChunkBytes
description: Writes buf to stream (via deferred-write list when the stream lacks IFFF_RSEEK), tracks cn_Scan.
lvo: -66
registers: a0,a1,d0
timestamp: 2026-10-10T18:00:00Z
---

# `LONG WriteChunkBytes(iff,buf,numBytes)`

**LVO -66** — registers `a0,a1,d0`

Writes buf to stream (via deferred-write list when the stream lacks IFFF_RSEEK), tracks cn_Scan.
