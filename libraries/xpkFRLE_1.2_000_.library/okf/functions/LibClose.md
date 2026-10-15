---
type: Function
title: LibClose
description: Library close vector.
---

# LibClose — LVO -12

`subqw #1,OpenCnt; bne.w -> hunk+0` -- non-zero counts return
0 through the *entry stub* (moveq#0/rts).  On zero: `btst
#3,lib_Flags`; DELEXP clear -> `beq.w hunk+0` (same stub),
else falls into the expunge path.  Both exits are forced-word
branches to hunk+0 -- the shared-stub trampoline is a size
optimisation.
