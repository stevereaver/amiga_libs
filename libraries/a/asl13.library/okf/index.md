---
type: Library
title: asl13.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:13.509882Z
---

# asl13.library

## Structure scan

```
romtag@4 flags=80 ver=34 type=9 pri=0
  name[3c]='' idstr[4a]='' init=2c endskip=1e
  inittab: datasize=2dc functab@41f90000 datatab@b1c9 initfunc=660e323c

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
