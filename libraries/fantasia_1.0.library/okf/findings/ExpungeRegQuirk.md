---
type: Finding
title: Expunge movem mismatch
description: Pushes d1/a5-a6, pops d2/a5-a6 — caller's d2 receives its old d1.
timestamp: 2026-10-10T18:00:00Z
---

# Expunge movem mismatch

`movem.l d1/a5-a6,-(sp)` at entry but `movem.l (sp)+,d2/a5-a6` on
exit: a5/a6 restore correctly, but the slot that saved d1 is popped
into d2 (which the body also used for the seglist).  Net caller
effect: d2 = caller's old d1 after return.  Semantically harmless;
the C reconstruction restores registers conventionally — documented
as a deliberate deviation.
