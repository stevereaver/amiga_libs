---
type: Function
title: LibInit
description: Init routine — movec-pcr probe; 060 → open 68060.library, 040 → preload then die.
lvo: null (AUTOINIT init routine, entered with d0=base, a0=seglist, a6=SysBase)
---

# `struct Library *LibInit(base, seglist)`

**Init routine** — `d0`=base, `a0`=seglist, `a6`=SysBase

```c
base->pb_SysBase = SysBase;
base->pb_SegList = seglist;
base->pb_DOSBase = OpenLibrary("dos.library", 0);
if (!base->pb_DOSBase) return NULL;
if (!(SysBase->AttnFlags & AFF_68040)) return NULL;   /* btst #3,(297,a6) */

if (Probe() == 1) {                       /* real 68060 */
    base->pb_OpenLib = OpenLibrary("68060.library", 0);
    if (!base->pb_OpenLib) return NULL;
    return base;
}
/* real 68040: */
base->pb_LoadLib = LoadAndInit("68040new.library");
if (!base->pb_LoadLib)
    base->pb_LoadLib = LoadAndInit("68040old.library");
return NULL;                              /* always: preload-then-die */
```

The probe (`Supervisor()`-wrapped):

```
movec vbr,a0; save vec[4]; install fault-handler; d0=1
movec pcr,a1            ; 4e7a 9808 — legal only on 68060
restore vec[4]; rte
fault: PC+=4; d0=0; rte
```

- `LoadAndInit` = `LoadSeg("LIBS:"+name)` → RomTag scan of the
  seglist → `InitResident(resident=a1, segList=d0)` — the seglist is
  passed in **d0**, not the documented d1 (see findings).
