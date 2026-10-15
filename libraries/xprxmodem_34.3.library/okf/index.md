---
type: Library
title: xprxmodem_34.3.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:29.565488Z
---

# xprxmodem_34.3.library

## Structure scan

```
romtag@4 flags=80 ver=34 type=9 pri=0
  name[34]='f\x0e2<' idstr[46]='\x85ÎNº' init=24 endskip=1e
  inittab: datasize=48e78080 functab@612a43ec datatab@85ce41ec initfunc=85ceb1c9

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
