---
type: Library
title: mmu_0.00(30.08.98).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:55.717511Z
---

# mmu_0.00(30.08.98).library

## Structure scan

```
romtag@4 flags=80 ver=0 type=9 pri=0
  name[40]=' \n(@)N' idstr[90]='N®ýÒ\x08,' init=0 endskip=0
  inittab: datasize=70ff4e75 functab@4afc0000 datatab@40000 initfunc=8000

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
