---
type: Finding
title: Quirks and open questions
---

# Quirks — 68040.library 46.5 (Phase5)

- **060 detection by `movec pcr` probe** (replacing the 44.1 dummy's
  AttnFlags bit tests): Supervisor() installs a temporary
  illegal-instruction handler, executes `movec pcr,a1`
  (`4e7a 9808`, control reg 0x808 — 68060-only), and returns 1 when
  it executes. The probe catches the case where a 68060 system
  reports AFB_68040 for compatibility.
- **060 path:** `OpenLibrary("68060.library")` — pointer is +5 into
  `"LIBS:68060.library"` (basename), stored at pb_OpenLib; LibOpen
  hands it out → callers of "68040.library" get the real 060 lib.
  (The older 44.1 dummy uses the same +5 scheme — an earlier note
  claiming it opened `"060.library"` at +7 was wrong; oracle-verified.)
- **Real-040 path:** `LoadSeg("LIBS:68040new.library")` /
  `…old.library` + InitResident, then always NULL → the stub unloads
  itself leaving the real lib resident (preload-then-die). The
  RomTag scan walks seglists reading the allocation size at seg-4.
- **InitResident ABI quirk:** seglist in d0 rather than documented
  d1; d1 still holds the LoadSeg name pointer. Harmless in the
  success path.
- LibClose/Expunge/ExtFunc are all null stubs; OpenCnt is never
  decremented — permanent resident.
- Rebuild: `source/68040_v.s` verbatim asm + `fixup.py` (rewrites
  RELOC32 → the original's 0x3f7 DREL16 tail with out-of-order
  offsets a,12,16,1a,d8-ec,f0,110,fe,6) → byte-identical
  (md5 8333b7778869e23f481d32c03cf48f30). Old C model kept as
  `make cmodel`.
