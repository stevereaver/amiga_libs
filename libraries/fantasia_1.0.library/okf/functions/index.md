---
type: Index
title: Functions
description: Exported functions and LVO entries analyzed for this library.
---

# Functions

Function table (absolute longs at code+0x62): Open, Close, Expunge,
Reserved, LIBFUNC_0, LIBFUNC_1, `-1`.

- [LibOpen](LibOpen.md) — LVO -6
- [LibClose](LibClose.md) — LVO -12 (tests flag via caller's a5 — bug)
- [LibExpunge](LibExpunge.md) — LVO -18
- [ExtFunc](ExtFunc.md) — LVO -24, `moveq #0,rts`
- [JoyDir](JoyDir.md) — LVO -30, JOY1DAT decode → d3
- [JoyButtons](JoyButtons.md) — LVO -36, CIAA/POTGOR decode → d2
- [LibInit](LibInit.md) — InitTable init routine
