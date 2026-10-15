---
type: Finding
title: Buggy 1.1 Expunge
description: Remove() node in a0 (documented ABI is a1); wild FreeMem math.
timestamp: 2026-10-10T19:00:00Z
---

# Buggy Expunge in version.library 1.1

Two defects in the LVO -18 routine (reproduced verbatim in
`source/expunge.s`):

1. `movea.l a5,a0 / jsr -252(a6)` calls exec `Remove()` with the
   node in **a0**; Remove's documented register is **a1** on every
   exec from 1.3 on (`fd13/exec_lib.fd`).  Unless Kickstart 1.1's
   Remove genuinely took a0, the unlink runs on a garbage pointer.
2. The FreeMem block/size use **longword** reads at offsets 16/18:
   `move.l 16(a5),d0` picks up `(NegSize<<16)|PosSize`, `suba.l
   d0,a1` pushes the block start megabytes below the base, and
   `add.l 18(a5),d0` adds `(PosSize<<16)|lib_Version` — a wild free.

Later builds (33.1 on) use `movea.l a5,a1` for Remove and word reads
(`move.w 16/18`) computing `NegSize + PosSize`.  The 1.1 defect is a
plausible root cause of the period folklore that expunging
version.library crashes 1.x systems.
