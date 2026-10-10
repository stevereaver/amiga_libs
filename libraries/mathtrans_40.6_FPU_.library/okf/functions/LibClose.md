---
type: Function
title: LibClose
description: LVO -12 -- close the library, expunge if deferred.
---

# LibClose — LVO -12

Decrements `lib_OpenCnt`; nonzero -> return 0.  At zero, a set
DELEXP bit (base+0x2a bit3) runs the expunge sequence
(Remove + FreeMem, returns the seglist); otherwise returns 0.
