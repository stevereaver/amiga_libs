---
type: Function
title: JoyDir (name inferred)
description: Decodes JOY1DAT quadrature into a 0-8 direction/state index in d3.
lvo: -30
registers: result in d3 (NOT d0); clobbers d0,d4,d5; reads $DFF00C repeatedly
timestamp: 2026-10-10T18:00:00Z
---

# `LONG JoyDir(void)` — result in d3

**LVO -30** (code+0x138)

Reads `JOY1DAT` ($DFF00C, joystick port 1 quadrature counter):

- bit 9 set → upper map: `(d4 ^ d4>>1) bit0` → 6; else bit8 → 7,
  else 8.
- bit 9 clear → `(d4 ^ d4>>1) bit0` → test bit1: set → 4, else 5;
  bit0 clear + bit8 set → bit1 ? 2 : 1;
  else → bit1 ? 3 : 0.

Returns d3 ∈ {0..8} — a 9-way direction/state index (numeric
keypad-style).  Note: JOY1DAT is re-read at several points, so the
result can reflect a changing stick position; d0 is left holding
the last read.  Name inferred — no FD exists.
