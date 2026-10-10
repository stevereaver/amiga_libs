---
type: Function
title: JoyButtons (name inferred)
description: Decodes CIAA PRA bit7 + POTGOR bits 14/12 into a 0/1/2/4 index in d2.
lvo: -36
registers: result in d2 (NOT d0); clobbers d0; reads $BFE001 and $DFF016
timestamp: 2026-10-10T18:00:00Z
---

# `LONG JoyButtons(void)` — result in d2

**LVO -36** (code+0x20c)

- `btst #7,$BFE001` (CIAA PRA — joy1 fire, active low)
  - fire pressed (bit clear) → POTGOR bit14: set → d2=1, clear →
    d2=4
  - fire not pressed → POTGOR bit14 set → d2=0; clear → POTGOR
    bit12: set → d2=2, clear → d0/d2 stay 0.

Tail merges use absolute `jmp` (hence REL32 relocs inside this
function in the original); three `jmp`s are unreachable dead code.
Name inferred — no FD exists.
