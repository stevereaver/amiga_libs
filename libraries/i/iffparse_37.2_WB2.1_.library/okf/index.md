---
type: Library
title: iffparse_37.2(WB2.1).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:53.060457Z
---

# iffparse_37.2(WB2.1).library

## Structure scan

```
romtag@3a flags=80 ver=37 type=9 pri=0
  name[54]='iffparse.library' idstr[65]='iffparse.library 37.2 (23.7.91)\r\n' init=0 endskip=160
  inittab: datasize=43f90000 functab@9d7000 datatab@2c780004 initfunc=2a4e4eae

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
