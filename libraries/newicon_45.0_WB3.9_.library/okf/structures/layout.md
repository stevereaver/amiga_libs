---
type: Structures
title: newicon 45.0 layout
---

# Layout

- datasize 0x32 -> 34B node + 0x18B private.
- DATA hunk packs functab@0 + strings + InitTable@0x90 +
  Resident@0xa0 + 'DON'T EDIT' banner + IM1=/IM2= icon-marker
  strings at 0xe0+.
- DREL16 (0x3f7) relocations: word-offset groups of
  count(2)+hunkno(2)+offsets[n*2], no padding.
