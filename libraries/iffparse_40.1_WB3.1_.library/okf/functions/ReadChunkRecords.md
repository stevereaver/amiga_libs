---
type: Function
title: ReadChunkRecords
description: numBytes = recSize*numRecs via SMult32 cache, then ReadChunkBytes.
lvo: -72
registers: a0,a1,d0,d1
timestamp: 2026-10-10T18:00:00Z
---

# `LONG ReadChunkRecords(iff,buf,recSize,numRecs)`

**LVO -72** — registers `a0,a1,d0,d1`

numBytes = recSize*numRecs via SMult32 cache, then ReadChunkBytes; result SDivMod32 back to whole records.
