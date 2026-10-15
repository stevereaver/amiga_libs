---
type: Finding
title: RebuildDeviations
description: Where the reconstruction differs from the shipped binary.
timestamp: 2026-10-10T20:20:00Z
---

# Rebuild deviations

- gas resolved global *loads* as PC-relative (`moveal %pc@(...)`)
  where the original used absolute-long addressing (`moveal
  abs.l`); stores remain absolute.  Semantics identical, code is
  ~0x10 bytes shorter and emits fewer reloc32 records.
- A couple of branches assemble as word branches where the
  original used short branches.
- Function order within the code hunk follows the LVO order;
  the original stored the -114/-120 pair in reverse physical
  order.  Vector order is identical.
