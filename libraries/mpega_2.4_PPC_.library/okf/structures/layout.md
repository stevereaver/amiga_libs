---
type: Structures
title: mpega.library 2.4 (PPC) memory layout
---

# Layout

datasize 0x2a -> lib base allocation of 34 + 0x2a = 76 bytes
(std 34-byte Library node + 42 private).

Private fields observed:
- +0x22 (34): seglist (initfn stores a0)
- +0x26 (38): execbase (initfn stores a6)

DATA hunk globals (a4-relative):
- a4+0x40: execbase mirror used by expunge (`a4@(64)` -> exec -252 Remove)
- strings and the embedded Resident at a4+0x100
