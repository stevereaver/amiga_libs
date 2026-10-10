---
type: Function
title: LibInit
description: InitTable init routine; stores seglist at +0x2a.
lvo: -
registers: d0 = libbase, a0 = seglist, a6 = ExecBase
timestamp: 2026-10-10T18:00:00Z
---

# `struct Library *LibInit(struct AslShimBase *base __asm("d0"), ULONG seglist __asm("a0"))`

**code+0x94** — entry params d0/a0/a6

`movem a5,-(sp); movea.l d0,a5; move.l a0,42(a5); movem (sp)+,a5; rts`
— stores the segment list at +0x2a and returns the base.  Notably it
does **not** initialise +0x22 (the OpenLibrary pointer used by the
relay tail) — see
[findings/UninitializedOpener](../findings/UninitializedOpener.md).
