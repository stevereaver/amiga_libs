---
type: Structures
title: iconobject.library 40.8 layout
---

# Layout

- datasize 0x6c -> 34B node + 108B private (dos/intuition/utility
  bases, msg port, state).
- a4-relative global data against the DATA hunk (SAS/C model):
  all `lea DATAhunk,a4` preambles with relocated operands.
