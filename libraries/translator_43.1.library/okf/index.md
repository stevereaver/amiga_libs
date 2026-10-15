---
type: Library
title: translator_43.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:49.333961Z
---

# translator_43.1.library

## Structure scan

```
romtag@4 flags=80 ver=43 type=9 pri=0
  name[24]='\x01&*@+H' idstr[38]='' init=20 endskip=1e
  inittab: datasize=514f48e7 functab@1262a40 datatab@2b480022 initfunc=1b7c0009

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
