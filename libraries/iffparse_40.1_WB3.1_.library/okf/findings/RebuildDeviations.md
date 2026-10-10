---
type: Finding
title: Rebuild deviations
description: Ways the reconstructed binary differs from the original.
timestamp: 2026-10-10T18:00:00Z
---

# Rebuild deviations

Semantics match; the generated code differs in expected ways:

- **Code size**: .text 0x1f94 vs original 0x1974 (~4% larger).
  Modern GCC -O2 vs 1993 Lattice/SAS codegen; the original also
  uses `link/unlk` frames everywhere while we use
  -fomit-frame-pointer.
- **Extra .bss hunk (4 bytes)**: holds the file-scope `IFFBase`
  pointer.  The original carries the base in a6 through every call;
  we store it once in LibInit (equivalent for a single-instance
  library, and required because NDK `*_BASE_NAME` macros expand
  inside header helper functions).
- **rt_EndSkip**: original 0x1964 (near module end); ours points at
  end of .text.  Semantically equivalent for a disk-resident
  library.
- **Self-calls**: the original calls its own LVOs via `jsr -N(a6)`
  (e.g. InitIFFasDOS calls `jsr -228(a6)`); the reconstruction uses
  ordinary direct calls.  Same effect.
- **Register allocation** differs throughout (a5-frames vs a2-based
  addressing); also the original shares tiny subroutines
  (MinList-init at 0x1964, openlib+fail at 0x106/0x1be) which GCC
  inlines.
- **LibInit store order**: original branches on the OpenLibrary
  result before storing; we store then branch — identical outcome
  (on failure both fields are closed then NULL is returned).
