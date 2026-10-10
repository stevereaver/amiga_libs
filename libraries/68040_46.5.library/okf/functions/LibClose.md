---
type: Function
title: LibClose
description: Null stub — never decrements OpenCnt.
lvo: -12
registers: d0 = 0 (out)
---

# `LONG LibClose(void)`

**LVO -12** — `moveq #0,d0/rts`. The original never decrements the
open count incremented by LibOpen, so the library stays resident
(deliberate leak).
