---
type: Library
title: xprkermit_1.5.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:24.138061Z
---

# xprkermit_1.5.library

## Structure scan

```
romtag@1750 flags=80 ver=1 type=9 pri=0
  name[0]='NUÿ\xa0B¬\x88v/-' idstr[12]='+@ÿ\xa0f\x06p' init=158 endskip=176a
  inittab: datasize=2b7c0000 functab@8ffa4 datatab@4aac8876 initfunc=670a41fa

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
