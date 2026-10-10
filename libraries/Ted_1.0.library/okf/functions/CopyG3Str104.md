---
type: Function
title: CopyG3Str104
description: Copy the string at *(g3+104) into the scratch buffer.
lvo: -102
registers: -> d0 buf
timestamp: 2026-10-10T20:20:00Z
---

# ``STRPTR CopyG3Str104(void)``

**LVO -102**

`strcpy(buf, *(g3+104))` byte loop; returns the buffer address.
