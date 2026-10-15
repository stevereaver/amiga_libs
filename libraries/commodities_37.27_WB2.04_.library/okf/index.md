---
type: Library
title: commodities_37.27(WB2.04).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:36.367739Z
---

# commodities_37.27(WB2.04).library

## Structure scan

```
romtag@4 flags=80 ver=37 type=9 pri=0
  name[10]='\t' idstr[24]='#Î' init=0 endskip=1e
  inittab: datasize=70ff4e75 functab@4afc0000 datatab@40000 initfunc=1e8025

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
