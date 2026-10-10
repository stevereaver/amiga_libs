---
type: Finding
title: Quirks and open questions
---

# Quirks — 68040.library 46.9 (Lynxx)

- **"+2" name pointers.** Both library names are referenced two bytes
  into the stored strings: `OpenLibrary("060.library")` (into
  "68060.library") and `LoadSeg("bs:68040mmu.library")` (into
  "Libs:68040mmu.library"). The same pattern exists in the Phase5
  68040dummy 44.1 binary (there +7 into "LIBS:68060.library",
  i.e. also "060.library"). Whether "060.library" is an intended
  third-party library name or an off-by-two bug is an open question;
  the "bs:" LoadSeg target, however, cannot ever succeed — the
  intended "Libs:68040mmu.library" preload is dead code.
- **exec LVO -810 = TaggedOpenLibrary(tag)** (exec_lib.i; the older fd
  still calls it execPrivate17). Called unconditionally with tag=4 —
  on an exec without that vector this jumps into the gap between
  exec's jump table and base. The systems this loader targets
  (OS 3.1.4/3.2-era, exec V45+) implement it; tag 4 yields the
  dos.library base used for the LoadSeg calls.
- **Probe = `movec pcr` (0x808)** under a patched illegal-instruction
  vector: returns 1 on 68060 (PCR exists), 0 on real 68040 — the
  classic 040/060 distinguisher.
- **Preload-then-die on real 68040:** the 040 branch always returns
  NULL after the (broken) LoadSeg, so the stub unloads itself.
- **InitResident ABI quirk:** the seglist is passed in d0, not d1 as
  the published signature requires; d1 at that point holds a stale
  LoadSeg-name pointer. Works because InitResident only uses the
  seglist on the failure path. Reproduced verbatim via an asm shim.
- No user LVOs; OpenCnt is never decremented (Close is a null stub
  shared with Expunge/ExtFunc) — permanent resident.
