---
type: Finding
title: RebuildDeviations
description: Where the reconstruction differs from the shipped binary.
timestamp: 2026-10-10T19:00:00Z
---

# Rebuild deviations

- Code hunk is 0x31c vs the original 0x2ec (GCC output is slightly
  larger; all vector semantics match).
- The rebuilt hunk contains reloc32 entries (original stores the
  same pointers but the file layout differs slightly in header
  detail: the original also emits empty DATA/BSS hunks).
- A latent bug in an earlier draft C copy loop
  (`*d++ = *s = *portname++` wrote past the end of the caller's
  string) was corrected to a plain byte copy matching the asm.
