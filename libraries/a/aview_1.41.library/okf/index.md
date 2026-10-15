---
type: Library
title: aview_1.41.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:58.093412Z
---

# aview_1.41.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[4e]='aview.library' idstr[aa]='$VER: AView 1.41 (10.11.97)' init=1e endskip=1f0c
  inittab: datasize=8a functab@d8 datatab@2e initfunc=112
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
