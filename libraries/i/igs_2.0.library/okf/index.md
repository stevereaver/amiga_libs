---
type: Library
title: igs_2.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:22:00.845586Z
---

# igs_2.0.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[1e]='igs.library' idstr[2a]='Intuition and G(adtools|raphics) Support Library V 2.0 15-Jan-1994\n(c) 1993,4 Misoftware computing' init=8e endskip=20bc
  inittab: datasize=4a functab@ca datatab@9e initfunc=10c
  functab: 0 vectors (abs-long)

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
