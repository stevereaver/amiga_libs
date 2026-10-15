---
type: Library
title: ptable_2.0(000).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:28.180188Z
---

# ptable_2.0(000).library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=22
  name[1e]='ptable.library' idstr[33]='ptable.library 2.0 (11.09.2026) [68000]\n' init=5c endskip=2e1c
  inittab: datasize=2a functab@6c datatab@0 initfunc=86
  functab: 0 vectors (abs-long)

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
