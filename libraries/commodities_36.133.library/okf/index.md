---
type: Library
title: commodities_36.133.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:30.614713Z
---

# commodities_36.133.library

## Structure scan

```
romtag@4 flags=80 ver=36 type=9 pri=0
  name[10]='\t' idstr[24]='#Î' init=0 endskip=1e
  inittab: datasize=70ff4e75 functab@4afc0000 datatab@40000 initfunc=1e8024

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
