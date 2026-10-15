---
type: Function
title: LibExpunge
description: Low-memory alert trigger; never expunges, always returns 0.
lvo: -18
registers: a6 base
timestamp: 2026-10-10T19:00:00Z
---

# ``LONG LibExpunge(void)``

**LVO -18** — `a6` = library base

Repurposed as the alert trigger.  Walks the client list
(base+0x2a); for each node:

1. `FindPort(ln_Name)` — skip if the client's port is gone.
2. If `msg+20` (the `LowMemMsg.lm_flag`) is still
   `LM_CONDITION_ACKNOWLEDGED` ('ASDG'): clear it to 0
   (`LM_LOW_MEMORY_CONDITION`), re-init the message
   (`ln_Type`=NT_MESSAGE 5, `mn_ReplyPort`=NULL, `ln_Pri`=0,
   `mn_Length`=4) and `PutMsg()` it to the found port.

Always returns 0 — the real teardown happens in Close when the
private open count reaches zero.
