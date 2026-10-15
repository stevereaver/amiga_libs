---
type: Library
title: mathieeedoubtrans_45.3(WB3.9).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:22:59.723424Z
---

# mathieeedoubtrans_45.3(WB3.9).library

## Structure scan

```
romtag@4 flags=01 ver=45 type=9 pri=0
  name[1e]='mathieeedoubtrans.library' idstr[38]='mathieeedoubtrans.library 45.3 (23.11.2000)\r\n' init=9e endskip=2284
  inittab: datasize=23c80000 functab@20223ce datatab@70 initfunc=48e70820

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
