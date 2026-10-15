---
type: Finding
title: Quirks and open questions
---

# Quirks — 68040.library 44.1 (Phase5 dummy)

- **Bare-name pointer trick.** All four name `lea`s point 5 bytes
  into the `"LIBS:<name>"` strings, i.e. at the bare library names.
  OpenLibrary("dos.library") / OpenLibrary("68060.library") get the
  bare names; the LoadSeg helper passes `name-5` to reach the
  `LIBS:`-prefixed path. (An earlier version of this note claimed
  the 060 branch opened `"060.library"` at +7 — wrong; the oracle
  log shows `OpenLibrary("68060.library")`.)
- **68060 fast path.** `AFF_68060` short-circuits init to success —
  the stub installs itself on 060 systems but forwards nothing
  (pb_OpenLib stays NULL → LibOpen returns the stub itself, whose
  jump table ends at LVO -24).
- **Preload-then-die on real 040.** With AFF_FPU40 the code
  LoadSegs `LIBS:68040new.library` (then `…old.library`) and
  InitResidents it, then returns NULL — the stub is unloaded but the
  preloaded library stays in exec's resident list. The 68040new/old
  libs are Phase5's real CPU-support libraries.
- **InitResident ABI quirk.** seglist passed in d0 instead of d1;
  d1 still holds the (already consumed) LoadSeg name pointer.
  Works because InitResident only touches the seglist on failure.
- **RomTag scan.** Seglist walk reads the allocation size at seg-4
  and the next-BPTR at seg+0, then scans words for 0x4afc where the
  long at matchword+2 points back at itself.
- LibClose/Expunge/ExtFunc are all null stubs; OpenCnt is never
  decremented — permanent resident.
