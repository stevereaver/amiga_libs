---
type: Function
title: LibInit
description: Stores SysBase/seglist, opens dos.library v1; always returns the base.
lvo: -
registers: d0 = libbase, a0 = seglist, a6 = ExecBase
timestamp: 2026-10-10T18:00:00Z
---

# `struct Library *LibInit(struct FantasiaBase *base __asm("d0"), ULONG seglist __asm("a0"))`

**code+0x9a** — entry params d0/a0/a6

```
a5 = d0
+0x22 = a6            /* ExecBase  */
+0x2a = a0            /* seglist   */
+0x26 = OpenLibrary("dos.library", 1)
bne.l +4             /* 66ff 0000 0004 — never-taken 020-form */
return a5            /* always, even if dos open failed */
```
