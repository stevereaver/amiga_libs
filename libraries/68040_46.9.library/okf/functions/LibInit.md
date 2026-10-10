---
type: Function
title: LibInit
description: Init routine — TaggedOpenLibrary(4), AttnFlags gate, PCR probe, forward-or-preload.
lvo: null (AUTOINIT init routine, entered with d0=base, a0=seglist, a6=SysBase)
---

# `struct Library *LibInit(base, seglist)`

**Init routine** — `d0`=base, `a0`=seglist, `a6`=SysBase

```c
base->lb_SysBase = SysBase;
base->lb_SegList = seglist;
base->lb_DOSBase = TaggedOpenLibrary(4);   /* exec LVO -810; unchecked */
if (!(SysBase->AttnFlags & AFF_68040)) return NULL;
if (Supervisor(ProbeBody)) {               /* movec pcr works: 68060 */
    base->lb_OpenLib = OpenLibrary("060.library", 0);  /* str+2 quirk */
    if (!base->lb_OpenLib) return NULL;
    return base;
}
(void)LoadAndResident("bs:68040mmu.library"); /* str+2 quirk */
return NULL;                               /* always fails */
```

Notes:

- `TaggedOpenLibrary` is exec LVO -810 (exec V45+); tag value 4
  yields the internal dos.library base on the systems this loader
  targets. The result is stored unconditionally.
- `ProbeBody` runs in supervisor mode: it swaps exception vector 4
  (illegal instruction), executes `movec pcr,a1` (control reg 0x808,
  implemented only on the 68060), restores the vector and returns
  via RTE. On a 68040 the instruction traps and the handler returns 0.
- `LoadAndResident` = LoadSeg → RomTag scan of the seglist →
  InitResident(resident=a1, segList=**d0**) — the original passes the
  seglist in d0 although the published ABI uses d1 (see findings).
