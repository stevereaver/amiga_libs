---
type: Structures
title: asyncio.library 39.1 layout
---

# Layout

- datasize 0x22 -> 34-byte Library node + 42 bytes private.
- hunk1 = 20-byte BSS referenced by 10 relocated code operands —
  global counters/bases (dos/utility base pointers, port state).
- Private fields used by initfn/lifecycle: seglist and lib base
  pointers stored in the private region (init stores a0/a6).
