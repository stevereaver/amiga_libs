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
    base->lb_OpenLib = OpenLibrary("68060.library", 0);
    if (!base->lb_OpenLib) return NULL;
    return base;
}
(void)LoadAndResident("Libs:68040mmu.library");
return NULL;                               /* always fails */
```

Notes:

- `TaggedOpenLibrary` is exec LVO -810 (exec V45+); tag value 4
  yields the internal dos.library base on the systems this loader
  targets. The result is stored unconditionally.
- `ProbeBody` runs in supervisor mode: `movec vbr,a0`, swaps
  exception vector 4 (illegal instruction) at `a0+0x10`, executes
  `movec pcr,a1` (control reg 0x808, implemented only on the 68060),
  restores the vector and returns via RTE. On any CPU without a PCR
  the instruction traps; the installed handler does
  `addq.l #4,2(sp)` — skipping the whole 4-byte `movec` — sets d0=0
  and RTEs back into the probe body's restore path.
- Both name `lea`s target the *starts* of the stored strings
  ("68060.library" @ +0x2c, "Libs:68040mmu.library" @ +0x3a) —
  oracle-confirmed; an earlier analysis that claimed `str+2`
  ("060.library"/"bs:...") pointers was wrong for this binary.
- `LoadAndResident` = LoadSeg → RomTag scan of the seglist →
  InitResident(resident=a1, segList=**d0**) — the original passes the
  seglist in d0 although the published ABI uses d1 (see findings).
  The scan bound is `seg[-4]` (remaining bytes, stepped `subq.l #2`
  per compared word); a resident matches on `0x4afc` + self
  `rt_MatchTag`.
