---
type: Function
title: IEEEDPFix
description: Double to long conversion — fmove.l, honours FPCR rounding mode.
lvo: -30
registers: d0/d1 double -> d0 long
timestamp: 2026-10-10T23:00:00Z
---

# ``LONG IEEEDPFix(double x)``

**LVO -30**

```asm
movem.l d0-d1,-(sp)
fmoved  (sp)+,fp0     ; fp0 = x
fmovel  fp0,d0        ; convert to long int
rts
```

`fmove.l fp0,d0` rounds per the **current FPCR mode** — the default
round-to-nearest means e.g. `IEEEDPFix(1.6) = 2`, while the
Kickstart convention for this vector is truncation toward zero
(1.6 → 1).  See [FixRounding](../findings/FixRounding.md).
