---
type: Function
title: CallG3Method100
description: Call *(g3+100) with a1 = scratch buffer; return the buffer pointer.
lvo: -96
registers: -> d0 buf
timestamp: 2026-10-10T20:20:00Z
---

# ``STRPTR CallG3Method100(void)``

**LVO -96**

Saves d2-d7/a2-a5, calls the function pointer at `g3+100` with
`a1` = the 255-byte code-hunk scratch buffer, restores registers
and returns the buffer address in d0.  The method presumably
writes a string into the buffer.
