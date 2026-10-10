---
type: Finding
title: Data cells inside the code hunk
description: Two writable longs (libbase, expname base) sit inside .text at 0x1f6/0x1fa; the libbase store is dead.
timestamp: 2026-10-10T18:00:00Z
---

# Data cells inside the code hunk

The compiler placed two 4-byte variables inside the code hunk:

- +0x1f6 — the library base, written once by LibInit
  (`move.l d0,abs`) and **never read** anywhere: a dead store,
  probably meant for a baserelative access model that was not used.
- +0x1fa — the expname.library base, written by LibInit, read
  PC-relative by BoardsFunc and Expunge.

Writable data in the code hunk is unusual but legal; the
reconstruction reproduces both cells in `source/boards_func.s`.
