---
type: Function
title: Reserved
description: Shared reserved stub returning 0.
lvo: -24, -30
registers: -
timestamp: 2026-10-10T20:00:00Z
---

# ``LONG Reserved(void)``

**LVOs -24 and -30**

Both slots point at the code-hunk stub `moveq #0,d0 / rts`
(code+0x06).  -24 is the exec-reserved slot; -30 is an unused
user slot.
