---
type: Function
title: IEEEDPFloor
description: fintrz for positive, FPCR round->-inf + fint for negative.
lvo: -90
registers: d0/d1 -> d0/d1
timestamp: 2026-10-10T23:00:00Z
---

# ``double IEEEDPFloor(double x)``

**LVO -90**

Two paths on the sign of x:

- `x >= 0`: `fintrzd (sp),fp0` — truncation *is* floor.
- `x < 0`: save FPCR (`fmovel fpcr,d0`→d1), set it to 0x20
  (round toward -infinity), `fint fp0,fp0`, restore FPCR, return
  via stack.  Saves/restores cleanly even though fint could have
  used the fint-with-mode trick instead.
