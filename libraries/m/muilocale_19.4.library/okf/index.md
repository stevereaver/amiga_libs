---
type: Library
title: muilocale_19.4.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:33.313578Z
---

# muilocale_19.4.library

## Structure scan

```
romtag@5a flags=00 ver=19 type=9 pri=0
  name[4]='muilocale.library' idstr[1c]='muilocale.library 19.14 (12.02.97) ©1992-1997 Stefan Stuntz\r\n' init=285e endskip=74
  inittab: datasize=48e72036 functab@24082a78 datatab@441f9 initfunc=2b10

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
