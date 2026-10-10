---
type: Function
title: PushChunk
description: Read mode: validates container (FORM/LIST/CAT/PROP) and type.
lvo: -84
registers: a0,d0,d1,d2
timestamp: 2026-10-10T18:00:00Z
---

# `LONG PushChunk(iff,type,id,size)`

**LVO -84** — registers `a0,d0,d1,d2`

Read mode: validates container (FORM/LIST/CAT/PROP) and type. Write mode: emits chunk header to stream (PROP skips GoodType). Allocates 40B ContextNode(flags 0).
