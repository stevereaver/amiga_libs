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
  Note the older 44.1 dummy opens `"060.library"` (+7) instead —
  behaviour change or bug fix, open question.
- **Real-040 path:** `LoadSeg("LIBS:68040new.library")` /
  `…old.library` + InitResident, then always NULL → the stub unloads
  itself leaving the real lib resident (preload-then-die). The
  RomTag scan walks seglists reading the allocation size at seg-4.
- **InitResident ABI quirk:** seglist in d0 rather than documented
  d1; d1 still holds the LoadSeg name pointer. Harmless in the
  success path.
- LibClose/Expunge/ExtFunc are all null stubs; OpenCnt is never
  decremented — permanent resident.
- Rebuild differences: semantic parity; gcc codegen differs (offset,
  regalloc), hunk layout and vector table format match.
