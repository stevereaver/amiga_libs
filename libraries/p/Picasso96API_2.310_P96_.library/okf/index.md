---
type: Library
title: Picasso96API_2.310(P96).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:11.761833Z
---

# Picasso96API_2.310(P96).library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[90]='Picasso96API.library' idstr[68]='Picasso96API.library 2.310 (17.10.01)\r\n' init=104 endskip=762
  inittab: datasize=44 functab@114 datatab@1c4 initfunc=1e8
  functab: 4 vectors (abs-long)
    LVO -6   -> 0258
    LVO -12  -> 0266
    LVO -18  -> 027a
    LVO -24  -> 02dc

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
