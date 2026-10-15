---
type: Function
title: XpksPackChunk
description: Always returns XPKERR_EXPANSION (-17); never packs.
lvo: -36
timestamp: 2026-10-10T19:45:00Z
---

# Signature

```c
LONG XpksPackChunk(struct XpkSubParams *xsp);  /* a0, ignored */
```

# Semantics

`moveq #-17,d0; rts` — unconditionally returns `XPKERR_EXPANSION`
(-17, "would have caused data expansion").

# Notes

A "NONE" chunk is raw stored data — copying it into an output buffer
with the xpk chunk header would only *expand* it, so the sublibrary
declines every pack request and xpkmaster stores the data itself.
Unpacking is still implemented ([XpksUnpackChunk](XpksUnpackChunk.md))
because existing "NONE-packed" streams must be readable.
