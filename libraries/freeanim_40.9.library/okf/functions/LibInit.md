---
type: Function
title: LibInit
description: InitTable init routine; stores seglist at +0x22, returns the base.
lvo: -
registers: d0 = libbase, a0 = seglist, a6 = ExecBase
timestamp: 2026-10-10T18:00:00Z
---

# `struct Library *LibInit(struct FreeAnimBase *base __asm("d0"), ULONG seglist __asm("a0"))`

**code+0x128** — entry params d0/a0/a6 (MakeLibrary convention)

`move.l a0,34(base)` then `rts` with d0 still holding the base —
returns the library base so MakeLibrary installs it.  ExecBase (a6)
is spilled to a scratch stack slot but never used.
