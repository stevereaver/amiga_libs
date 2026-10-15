---
type: Function
title: LibInit
description: Init routine — CPU-flag dispatch; preload 68040new/old or open "68060.library".
lvo: null (AUTOINIT init routine, entered with d0=base, a0=seglist, a6=SysBase)
---

# `struct Library *LibInit(base, seglist)`

**Init routine** — `d0`=base, `a0`=seglist, `a6`=SysBase

```c
base->pb_SysBase = SysBase;
base->pb_SegList = seglist;
base->pb_DOSBase = OpenLibrary("dos.library", 0);
if (!base->pb_DOSBase) return NULL;

if (SysBase->AttnFlags & AFF_68060) return base;   /* btst #7 → stay */
if (!(SysBase->AttnFlags & AFF_68040)) return NULL; /* btst #3 */

if (SysBase->AttnFlags & AFF_FPU40) {               /* btst #6 */
    base->pb_LoadLib = LoadAndInit("68040new.library"); /* LoadSeg LIBS: path */
    if (!base->pb_LoadLib)
        base->pb_LoadLib = LoadAndInit("68040old.library");
    return NULL;                                   /* always: preload-then-die */
}

base->pb_OpenLib = OpenLibrary("68060.library", 0); /* +5: skips "LIBS:" */
if (!base->pb_OpenLib) return NULL;
return base;
```

- `LoadAndInit` = `LoadSeg("LIBS:"+name)` → RomTag scan of the
  seglist → `InitResident(resident=a1, segList=d0)` (the seglist is
  passed in **d0**, not the documented d1 — reproduced verbatim).
- Note the 060 check runs *before* the 040 check: on a 68060 the
  stub installs itself without opening anything (pb_OpenLib stays 0,
  so LibOpen returns the stub's own base).
