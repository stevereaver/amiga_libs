---
type: Library
title: z_104.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:28:01.556917Z
---

# z_104.0.library

## Structure scan

```
romtag@4 flags=80 ver=104 type=9 pri=0
  name[60]='' idstr[6c]='*@d\x04p' init=1e endskip=4e
  inittab: datasize=22 functab@0 datatab@2e initfunc=50

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
