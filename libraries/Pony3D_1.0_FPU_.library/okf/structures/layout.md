---
type: Structures
title: Pony3D 1.0 layout
---

# Layout

- datasize 0x2a -> 34B node + 8B private.
- InitStruct datatab@h0+0x1a6 (byte commands).
- hunk2 is a pure string/data hunk (deps, credits, $VER).
- Four of eight vectors point into hunk1 — cross-hunk functab.
