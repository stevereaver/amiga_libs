---
type: Library
title: rexxdossupport_3.5.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:20.576276Z
---

# rexxdossupport_3.5.library

## Structure scan

```
romtag@4 flags=80 ver=3 type=9 pri=0
  name[5c]='rexxdossupport.library' idstr[74]='rexxdossupport 3.5 (6.2.97) Copyright © 1994-1997 by hartmut Goebel' init=1e endskip=d0
  inittab: datasize=22 functab@b8 datatab@2e initfunc=25c0
  functab: 3 vectors (abs-long)
    LVO -6   -> 2610
    LVO -12  -> 2636
    LVO -18  -> 2656

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
