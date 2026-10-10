---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-10
- Finished interrupted reconstruction: verified all 7 vectors and the
  InitStruct table against the IRA dump; fixed a copy-loop bug
  (write past end of source string) and added the pad byte before the
  idstring to match the original alignment; `make` produces a valid
  library.  Populated okf/.
- Confirmed `asdg-low-mem_0.0` == `asdg-low-mem(10-jun-87)` by sha256.
