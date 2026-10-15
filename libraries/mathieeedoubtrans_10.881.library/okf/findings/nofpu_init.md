---
type: Finding
title: No-FPU init path
description: Behaviour of the init routine when AttnFlags lacks AFF_68881.
---

# No-FPU init path (corrected)

On missing AFF_68881 the init routine (code+0x68) does:

```
move.l  d0,-(sp)              ; push the fresh library base
moveq   #36,d0                ; version 36
lea     "Libs:NoFPU/..."(pc),a1
jsr     -552(a6)              ; exec OpenLibrary -> d0
movea.l d0,a1
jsr     -414(a6)              ; exec CloseLibrary(result) -- runs even if 0
movea.l (sp)+,a1              ; a1 = the NEW base again
bra     0xd4                  ; shared Expunge free tail
```

The shared tail FreeMem()s `base - NegSize` of `NegSize + PosSize`
bytes and returns the longword at code+0x2c — the seglist cell, still 0
because the `move.l a0,(a1)` store on the FPU path was skipped — so the
resident init fails.

## Corrections vs the earlier note / C model

- The freed block is the **newly allocated library base**, not the base
  OpenLibrary returned.  The pushed base is restored into **a1** (the
  free-tail argument register), not d1 — it is not a dead restore.
- `OpenLibrary + CloseLibrary` of the fallback is a semantic no-op:
  whatever it returns (NULL or a live base) is closed again at once.
  It looks like a leftover attempt to pre-load the NoFPU software
  replacement — as written it can only ever warm/bump the open count
  transiently.  Verified by the oracle (`openlib`/`closelib`/`freemem`
  logged in that order, init returns 0, both for a NULL and a non-NULL
  OpenLibrary result).
- If OpenLibrary returned non-NULL, `CloseLibrary(a1)` on that library
  decrements its open count — potentially expunging it — before the new
  base is freed.  If it returned NULL, real exec CloseLibrary must cope
  with a NULL a1 (V36 does).
