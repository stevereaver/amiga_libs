---
type: Library
title: memoptimizer_4.093.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:32.633085Z
---

# memoptimizer_4.093.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=128
  name[1e]='memoptimizer.library' idstr[39]='memoptimizer.library 4.093 (19.12.10) Copyright © 2005-2010 RhoSigma, Roland Heyder\r\n' init=94 endskip=2eb8
  inittab: datasize=114 functab@a4 datatab@e8 initfunc=bb0
  functab: 16 vectors (abs-long)
    LVO -6   -> 1b30
    LVO -12  -> 1b48
    LVO -18  -> 1b5e
    LVO -24  -> 1cfe
    LVO -30  -> 1d02
    LVO -36  -> 2346
    LVO -42  -> 2416
    LVO -48  -> 25da
    LVO -54  -> 268a
    LVO -60  -> 27c6
    LVO -66  -> 2b26
    LVO -72  -> 2caa
    LVO -78  -> 2e0a
    LVO -84  -> 28c6
    LVO -90  -> 2a1a
    LVO -96  -> 2e66

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
