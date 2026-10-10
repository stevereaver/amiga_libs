---
type: Function
title: IEEEDPFlt
description: Long to double conversion via fp0 and the stack.
lvo: -36
registers: d0 long -> d0/d1 double
timestamp: 2026-10-10T23:00:00Z
---

# ``double IEEEDPFlt(LONG n)``

**LVO -36**

`fmovel d0,fp0; fmoved fp0,-(sp); move.l (sp)+,d0; move.l (sp)+,d1;
rts` — push-through trick: the converted double is moved back via
the stack into the return registers.
