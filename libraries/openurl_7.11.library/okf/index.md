---
type: Library
title: openurl_7.11.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:58.127886Z
---

# openurl_7.11.library

## Structure scan

```
romtag@d0 flags=80 ver=7 type=9 pri=0
  name[0]='openurl.library' idstr[16]='openurl.library 7.11 [OS3/m68k] (05.08.2012) Copyright (c) 2005-2012 openurl.library Open Source Team' init=c0 endskip=ea
  inittab: datasize=c4 functab@7c datatab@0 initfunc=ea
  functab: 16 vectors (abs-long)
    LVO -6   -> 02b6
    LVO -12  -> 02c8
    LVO -18  -> 0240
    LVO -24  -> 034a
    LVO -30  -> 197c
    LVO -36  -> 2232
    LVO -42  -> 223e
    LVO -48  -> 2274
    LVO -54  -> 2296
    LVO -60  -> 22ba
    LVO -66  -> 2084
    LVO -72  -> 1c22
    LVO -78  -> 22c6
    LVO -84  -> 1d52
    LVO -90  -> 1e84
    LVO -96  -> 22fa

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
