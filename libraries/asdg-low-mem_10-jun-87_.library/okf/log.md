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
- Binary is byte-identical to asdg-low-mem_0.0.library (same sha256).
  Reused that reconstruction's sources; `make` produces a valid
  library.  Populated okf/ (shared findings).
