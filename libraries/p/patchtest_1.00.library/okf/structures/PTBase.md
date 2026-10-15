---
type: Structure
title: PTBase
---

# Library base

Shipped dataSize 0x58 (SAS/C runtime layout):

| offset | field |
|--------|-------|
| 0x00-0x21 | struct Library |
| 0x22 | seglist |
| 0x2e | fixup-buffer ptr (0 in this build) |
| 0x32 | "parent" self ptr (== base for the master copy) |
| 0x36 | constant 30 (private-copy jump-table prefix size) |
| 0x3c | per-open data area (intuition base @+0x14 rel, sysbase @+0x18) |

Reconstruction uses a 0x2a base: lib + seglist@0x22 +
intuition base@0x26 -- the SAS/C tail fields were internal to
the copy machinery.
