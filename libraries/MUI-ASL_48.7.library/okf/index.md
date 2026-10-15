---
type: Library
title: MUI-ASL_48.7.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:42.045898Z
---

# MUI-ASL_48.7.library

## Structure scan

```
romtag@4 flags=00 ver=40 type=9 pri=0
  name[3d6]='MUI-ASL.library' idstr[3e6]='MUI-ASL 40.6 (02.10.97)\n\r' init=666 endskip=720c
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
