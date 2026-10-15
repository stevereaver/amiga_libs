---
type: Library
title: ILBM_(20 Jul 89).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:18:48.070186Z
---

# ILBM_(20 Jul 89).library

## Structure scan

```
romtag@2c flags=00 ver=0 type=9 pri=0
  name[195d]='ilbm.library' idstr[196a]='Dissidents ILBM lib, Jul 20 89\r\n' init=204 endskip=46
  inittab: datasize=2f0b47fa functab@ffc426c8 datatab@26ce7021 initfunc=43faffc2

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
