---
type: Function
title: LibInit
description: Stores base/SysBase/seglist, opens expname.library v1 into a code cell.
lvo: -
registers: d0 = libbase, a0 = seglist, a6 = ExecBase
timestamp: 2026-10-10T18:00:00Z
---

# `struct Library *LibInit(struct BoardsBase *base __asm("d0"), ULONG seglist __asm("a0"))`

**code+0x118** — entry params d0/a0/a6

```
movem.l d1-d7/a0-a6,-(sp)
selfbase      = d0            /* code cell +0x1f6 — dead store  */
base->SysBase = a6            /* +0x24 */
base->SegList = a0            /* +0x28 */
expnamebase   = OpenLibrary("expname.library", 1)  /* cell +0x1fa */
return expnamebase ? base : NULL
```

If expname.library is absent the init returns 0 and the library
fails to load entirely.
