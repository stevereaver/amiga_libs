---
type: Library
title: medplayer_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:52.560156Z
---

# medplayer_1.0.library

## Structure scan

```
romtag@4 flags=80 ver=5 type=9 pri=0
  name[48]='' idstr[5c]=' \x08;@' init=0 endskip=1e
  inittab: datasize=70004e75 functab@4afc0000 datatab@40000 initfunc=1e8005

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
