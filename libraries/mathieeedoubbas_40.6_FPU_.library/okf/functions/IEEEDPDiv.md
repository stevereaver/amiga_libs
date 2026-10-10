---
type: Function
title: IEEEDPDiv
description: 68881 fdivd through the stack.
lvo: -84
registers: d0/d1 left, d2/d3 right -> d0/d1
timestamp: 2026-10-10T23:00:00Z
---

# ``double IEEEDPDiv(double left, double right)``

**LVO -84**

Stack choreography in the original:

- Add/Mul: `movem.l d0-d3,-(sp)` then `fmoved (sp)+,fp0` takes
  the left operand; `fdivd (sp),fp0` consumes the right.
- Sub/Div: left pushed first (`movem.l d0-d1`), consumed into
  fp0, then right pushed for `fdivd (sp),fp0` — operand order
  preserved.

Result written over the stack top with `fmoved fp0,(sp)` and
popped into d0/d1.
