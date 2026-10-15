---
type: Library
title: MagicASL_40.7.m1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:43.767511Z
---

# MagicASL_40.7.m1.library

## Structure scan

```
romtag@4 flags=00 ver=40 type=9 pri=0
  name[3f0]='MagicASL.library' idstr[402]='MagicASL 40.7 (25.08.98)\n\r' init=688 endskip=7498
  inittab: datasize=48e7012e functab@2e082a4e datatab@82d0001 initfunc=1296606

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
