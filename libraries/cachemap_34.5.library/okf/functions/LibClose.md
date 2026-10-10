---
type: Function
title: LibClose
description: Decrements the private open count; never expunges.
lvo: -12
registers: a6 base
timestamp: 2026-10-10T19:30:00Z
---

# ``LONG LibClose(void)``

**LVO -12**

`subq.w #1,34(a6); moveq #0,d0; rts`.  Always returns 0 — closing
never triggers expunge (the real teardown is in the Expunge vector).
