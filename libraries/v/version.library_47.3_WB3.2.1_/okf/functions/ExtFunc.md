---
type: Function
title: ExtFunc
description: Reserved ExtFunc slot — standalone return-0 stub.
lvo: -24
registers: -> d0 0
timestamp: 2026-10-10T21:55:00Z
---

# ``LONG ExtFunc(void)``

**LVO -24**

```asm
moveq   #0, d0
rts
```

A separate stub at the end of the code hunk — not shared with
[LibExpunge](LibExpunge.md), which is a real routine in this
build.  No user functions exist; there is nothing at LVO -30 or
beyond.
