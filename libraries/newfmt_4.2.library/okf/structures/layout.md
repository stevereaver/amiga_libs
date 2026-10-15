---
type: Structures
title: newfmt 4.2 layout
---

# Layout

- datasize 0x104 -> 34B node + 0xe6B private.
- h1 = standalone 16B InitTable; h3 packs the functab,
  a second function-pointer table, name/id strings, and the
  'pcon:...' debug device string.
- initfn stores seglist at lib+0x22, sets LN_TYPE=9, name at
  +10, version byte 6 at +14.
