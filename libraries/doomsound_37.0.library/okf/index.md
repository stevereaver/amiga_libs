---
type: Library
title: doomsound_37.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:47.298634Z
---

# doomsound_37.0.library

## Structure scan

```
romtag@4 flags=80 ver=37 type=9 pri=0
  name[1e]='doomsound.library' idstr[30]='doomsound.library 37.0 (29.3.98) ©1998 by Joe Fenton.' init=68 endskip=174
  inittab: datasize=22 functab@78 datatab@c0 initfunc=e0
  functab: 17 vectors (abs-long)
    LVO -6   -> 0110
    LVO -12  -> 0120
    LVO -18  -> 0130
    LVO -24  -> 0170
    LVO -30  -> 0590
    LVO -36  -> 05a0
    LVO -42  -> 0610
    LVO -48  -> 0670
    LVO -54  -> 0690
    LVO -60  -> 06b0
    LVO -66  -> 06c0
    LVO -72  -> 0860
    LVO -78  -> 08a0
    LVO -84  -> 08b0
    LVO -90  -> 09e0
    LVO -96  -> 09f0
    LVO -102 -> 0a00

```

## Status

FULL - `source/` rebuilds byte-identical to `binary/` (verified by
fixup.py + cmp).  Per-vector C reference model: see source/ (or the
canonical API docs in okf/functions/).

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [algorithms/](algorithms/index.md)
- [log.md](log.md)
