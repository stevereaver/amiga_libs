---
type: Library
title: gadtools13_34.20.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:51.369973Z
---

# gadtools13_34.20.library

## Structure scan

```
romtag@4 flags=80 ver=34 type=9 pri=0
  name[6c]='' idstr[7f]='rary' init=5c endskip=1e
  inittab: datasize=660c2e3c functab@38007 datatab@4eaeff94 initfunc=60064eb9

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
