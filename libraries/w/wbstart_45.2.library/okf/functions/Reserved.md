---
type: Function
title: Reserved stub
description: Shared no-op vector returning 0.
lvo: -24
registers: -> d0 0
timestamp: 2026-10-10T21:10:00Z
---

# Reserved stub

**LVOs -24 and -30** both point at the same two-instruction stub:

```asm
clr.l   d0
rts
```

The 45.1 original used `moveq #0,d0` for the same purpose; the
emulation uses `clr.l d0`.  LVO -24 is the usual exec ExtFunc
slot; -30 would normally be the first user function, so this
library exports a single real API function at -36
([WBStart](WBStart.md)).
