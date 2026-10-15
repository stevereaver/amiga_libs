---
type: Library
title: ss_5.105.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:26.490787Z
---

# ss_5.105.library

## Structure scan

```
romtag@4 flags=80 ver=5 type=9 pri=0
  name[1e]='ss.library' idstr[2f]='Special Support Library 5.105\n(c) 1993-1995 MJSoft System Software' init=72 endskip=2d68
  inittab: datasize=8c functab@88 datatab@82 initfunc=146
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
