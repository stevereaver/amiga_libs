---
type: Library
title: mathieeedoubtrans_36.16.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:08.114787Z
---

# mathieeedoubtrans_36.16.library

## Structure scan

```
romtag@0 flags=01 ver=36 type=9 pri=0
  name[1a]='mathieeedoubtrans.library' idstr[34]='mathieeedoubtrans 36.16 (6 Dec 1989)\r\n' init=8a endskip=3e08
  inittab: datasize=23c80000 functab@23623ce datatab@8 initfunc=48e73020

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
