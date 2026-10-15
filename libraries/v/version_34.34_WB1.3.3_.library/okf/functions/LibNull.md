---
type: Function
title: LibNull
description: Reserved vector (ExtFunc slot), always returns 0.
lvo: -24
registers: -
timestamp: 2026-10-10T19:00:00Z
---

# `LONG LibNull(void)`

**LVO -24** — reserved/ExtFunc slot.

```
moveq   #0,d0
rts
```

version.library exports no user functions; this is the last vector.
