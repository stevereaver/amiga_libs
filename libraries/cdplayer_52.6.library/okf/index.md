---
type: Library
title: cdplayer_52.6.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:16:12.636741Z
---

# cdplayer_52.6.library

## Structure scan

```
romtag@148 flags=80 ver=52 type=9 pri=0
  name[210]='cdplayer.library' idstr[1eb]='cdplayer.library 52.6 (23.12.2011)' init=1d4 endskip=168
  inittab: datasize=6a functab@168 datatab@1b0 initfunc=44
  functab: 3 vectors (abs-long)
    LVO -6   -> 0124
    LVO -12  -> 00f8
    LVO -18  -> 00d8

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
