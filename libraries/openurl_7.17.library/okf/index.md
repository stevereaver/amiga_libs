---
type: Library
title: openurl_7.17.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:53.503772Z
---

# openurl_7.17.library

## Structure scan

```
romtag@d4 flags=80 ver=7 type=9 pri=0
  name[4]='openurl.library' idstr[1a]='openurl.library 7.17 [OS3/m68k] (04.08.2016) Copyright (C) 2005-2016 openurl.library Open Source Team' init=c4 endskip=ee
  inittab: datasize=c4 functab@80 datatab@0 initfunc=ee
  functab: 16 vectors (abs-long)
    LVO -6   -> 02c0
    LVO -12  -> 02d2
    LVO -18  -> 0244
    LVO -24  -> 035a
    LVO -30  -> 19dc
    LVO -36  -> 2158
    LVO -42  -> 2166
    LVO -48  -> 2174
    LVO -54  -> 219e
    LVO -60  -> 21ca
    LVO -66  -> 1fb6
    LVO -72  -> 1c52
    LVO -78  -> 21d8
    LVO -84  -> 220c
    LVO -90  -> 1dba
    LVO -96  -> 22be

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
