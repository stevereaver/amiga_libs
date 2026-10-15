---
type: Structures
title: newicon 44.3 layout
---

# Layout

- datasize 0x32 -> 34B node + 0x18B private; separate 12B BSS
  hunk.
- DATA hunk: functab@0 + strings + InitTable@0x90 +
  Resident@0xa0 (same arrangement as the 45.0 sibling).
- DREL16 tails: word groups count(2)+hunkno(2)+offsets[n*2],
  terminated by a bare zero word; a pad word aligns END to
  a long boundary when needed.
