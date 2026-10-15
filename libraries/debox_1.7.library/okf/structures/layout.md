---
type: Structures
title: debox 1.7 layout
---

# Layout

- InitStruct@+0x198 (datatab) consumed by MakeLibrary;
  dsize 0x6e -> 34B node + 76B private.
- Private: +34 execbase, +38 graphicsbase, +42 seglist,
  +14 flags (DELEXP bit3), +32 opencnt (word).
- initfn passes its own a0 (seglist) straight through.
