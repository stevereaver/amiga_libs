---
type: Finding
title: RebuildDeviations
description: Where the reconstruction differs from the shipped binary.
timestamp: 2026-10-10T19:30:00Z
---

# Rebuild deviations

- Code hunk is ~0x4a4 vs 0x39c in the original (GCC codegen is
  larger); all vector semantics were verified against the IRA dump.
- Function names (CreateMap/DeleteMap/etc.) are descriptive
  reconstructions — the original exports are unnamed.
- The original's single code hunk is reproduced; the rebuild emits
  reloc32 records for the functab/string pointers like the original.
