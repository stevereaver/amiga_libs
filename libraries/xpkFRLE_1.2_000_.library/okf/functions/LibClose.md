---
type: Function
title: LibClose
description: Library close vector.
---

# LibClose — LVO -12

`subqw #1,OpenCnt; bne.w -> hunk+2` -- non-zero counts return
through the *entry stub's rts* at hunk+0x02.  On zero: if
DELEXP clear, `bra.w hunk+0` (moveq#0/rts, returns 0); else
falls into the expunge path.  The shared-stub trampoline is a
size optimisation reproduced semantically in C.
