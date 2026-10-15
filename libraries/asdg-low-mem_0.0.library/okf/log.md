---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-15
- Byte-verbatim asm reconstruction (`source/asdg_h0.s`) +
  `fixup.py` (3-hunk envelope: CODE + empty DATA + empty BSS).
  `cmp` identical; `work/oracle.py` runtime-identical across
  all vectors and the expunge-drain path.

## 2026-10-10
- Finished interrupted reconstruction: verified all 7 vectors and the
  InitStruct table against the IRA dump; fixed a copy-loop bug
  (write past end of source string) and added the pad byte before the
  idstring to match the original alignment; `make` produces a valid
  library.  Populated okf/.
- Confirmed `asdg-low-mem_0.0` == `asdg-low-mem(10-jun-87)` by sha256.
