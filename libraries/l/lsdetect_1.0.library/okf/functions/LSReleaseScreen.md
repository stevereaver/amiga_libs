---
type: Function
title: LSReleaseScreen
description: Put back the borrowed ActiView and restore colour 0.
lvo: -36
registers: a6 base
timestamp: 2026-10-10T20:40:00Z
---

# ``void LSReleaseScreen(void)``

**LVO -36**

If the saved-view pointer (base+56) is non-NULL:

- `LoadView(view)`, `WaitTOF` twice (graphics base at +40).
- `SetRGB4(*(view), 0, r, g, b)` — first longword of the saved
  view is used as the "vp" (colormap pointer), r/g/b restored
  from the saved packed nibble long at base+60
  (r = bits 8-11, g = 4-7, b = 0-3).
- clears the saved-view pointer.
