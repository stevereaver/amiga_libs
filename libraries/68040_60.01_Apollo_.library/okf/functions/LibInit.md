---
type: Function
title: LibInit
description: Init routine — AttnFlags checks, then pre-opens "68o4o.library" or "68060.library".
lvo: null (AUTOINIT init routine, entered with d0=base, a0=seglist, a6=SysBase)
---

# `struct Library *LibInit(base, seglist)`

**Init routine** — registers `d0`=lib base, `a0`=seglist, `a6`=SysBase

Semantics (from disassembly @ INITFUNCTION):

```c
if (!(SysBase->AttnFlags & AFF_68040)) return NULL;   /* btst #3,(297,a6) */
if (SysBase->AttnFlags == 0x80ff) return NULL;        /* cmpi.w #$80ff,(296,a6) */
lib = OpenLibrary((AttnFlags & AFF_FPU40)
                  ? "68o4o.library" : "68060.library", 0);
if (!lib) return NULL;
return base;
```

- Nothing is stored — dataSize is 0x22 (bare `struct Library`), there
  is no room for private fields; the seglist is ignored entirely.
- The opened library's base is **not** kept; the open exists only for
  its side effect (the real library becomes resident and stays open).
- The 0x80ff compare checks the whole AttnFlags word; bit 15 is
  exec's "private use" flag, 0xff all low bits. Probably meant to
  reject emulation/ill-defined configs. See findings.
