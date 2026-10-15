---
type: Finding
title: Open questions
description: Not fully resolved.
timestamp: 2026-10-10T18:00:00Z
---

# Open questions

- **Runtime smoke test**: the rebuilt library was verified
  structurally (hunks, relocs, vector table, spot-checked codegen)
  but never executed.  A UAE/FS-UAE test that opens the library and
  round-trips an IFF file would be the next step.
- **+0x22 pad word in IFFBase**: never accessed by any code path;
  assumed alignment padding for the private fields, but it could be
  a vestigial word field from an earlier version.
- **EndSkip 0x1964**: the original points 0x10 bytes before the end
  of the code hunk, at the shared MinList-init subroutine.  Probably
  just "near end of module"; exact intent unknown.
- **Compiler identification**: codegen (link/unlk, a5 frames, `swap`
  for MEMF_CLEAR, shared helper subroutines) is consistent with
  SAS/C or Lattice C of the era but not conclusively identified.
