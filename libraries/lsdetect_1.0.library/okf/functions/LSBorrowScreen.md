---
type: Function
title: LSBorrowScreen
description: Stash ActiView, save and black colour 0, LoadView(0).
lvo: -42
registers: a6 base -> d0 0
timestamp: 2026-10-10T20:40:00Z
---

# ``LONG LSBorrowScreen(void)``

**LVO -42**

No-op (returns 0) if a view is already borrowed.  Otherwise takes
`GfxBase->ActiView` (gfxbase+34):

- stores it at base+56,
- `GetRGB4(*(colormap+4), 0)` → saved at base+60 — **verbatim**:
  the call is made on the longword at colormap+4 (the
  `ColorTable` pointer), not on the ColorMap itself,
- `SetRGB4(colormap, 0, 0, 0, 0)` — blacks entry 0,
- `LoadView(0)`, `WaitTOF` twice.

Always returns 0.
