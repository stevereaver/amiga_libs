---
type: Function
title: CallG3Method12
description: Tail-call the function pointer stored at g3+12.
lvo: -66
registers: passthrough
timestamp: 2026-10-10T20:20:00Z
---

# ``LONG CallG3Method12(...)``

**LVO -66**

`a1 = *(g3+12); jmp (a1)` — indirect tail call into a method of
the context structure; all argument/return registers pass through
unchanged.
