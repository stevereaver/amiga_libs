---
type: Library
title: 680x0_47.3.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:26.159859Z
---

# 680x0_47.3.library

## Structure scan

```
romtag@4 flags=80 ver=47 type=9 pri=0
  name[282]='680x0.library' idstr[2a2]='680x0.library 47.3 (7.12.2024) (c) 1999-2024 The MMU.lib development group, THOR\n\r' init=1e endskip=0
  inittab: datasize=48 functab@2e datatab@0 initfunc=56
  functab: 8 vectors (abs-long)
    LVO -6   -> 011c
    LVO -12  -> 012a
    LVO -18  -> 0138
    LVO -24  -> 0052
    LVO -30  -> 01d4
    LVO -36  -> 01dc
    LVO -42  -> 020a
    LVO -48  -> 023c

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
