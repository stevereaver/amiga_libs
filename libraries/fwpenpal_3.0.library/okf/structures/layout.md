---
type: Structures
title: fwpenpal 3.0 layout
---

# Layout

- datasize 0x22 -> 34B node + 0x0eB private.
- Everything (resident, strings, code, functab, InitTable)
  sits in hunk0 which is DATA-tagged; hunk1 is the CODE-tagged
  auxiliary routine block.
- Open returns the library base itself (lib=0x100000 under
  the oracle), not a per-open handle.
