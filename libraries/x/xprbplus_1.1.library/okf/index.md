---
type: Library
title: xprbplus_1.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:23.450340Z
---

# xprbplus_1.1.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=50
  name[42f0]='xprbplus.library' idstr[4304]='Version 1.0' init=4 endskip=1e
  inittab: datasize=4afc0000 functab@40000 datatab@1e8002 initfunc=9320000

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
