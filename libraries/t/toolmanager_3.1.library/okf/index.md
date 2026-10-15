---
type: Library
title: toolmanager_3.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:42.746497Z
---

# toolmanager_3.1.library

## Structure scan

```
romtag@42 flags=00 ver=3 type=9 pri=0
  name[4]='toolmanager.library' idstr[18]='$VER: toolmanager.library 3.1 (26.3.95)\r\n' init=98 endskip=5c
  inittab: datasize=48e72138 functab@2e0849f9 datatab@7ffe initfunc=294e800a

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
