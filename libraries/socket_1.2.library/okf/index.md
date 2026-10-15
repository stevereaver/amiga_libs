---
type: Library
title: socket_1.2.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:49.408731Z
---

# socket_1.2.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[292c]='socket.library' idstr[293c]='Version 1.0' init=4 endskip=1e
  inittab: datasize=4afc0000 functab@40000 datatab@1e8004 initfunc=9000000

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
