---
type: Library
title: xpkcybhandle_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:55.053506Z
---

# xpkcybhandle_1.0.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='xpkcybhandle.library' idstr[38]='xpkCybHandle.library v1.0 (30.July.96) © Alexis Nasr (The Cyborg)\r\n' init=7c endskip=7c
  inittab: datasize=6c functab@8c datatab@d8 initfunc=f8
  functab: 18 vectors (abs-long)
    LVO -6   -> 028e
    LVO -12  -> 029c
    LVO -18  -> 02b0
    LVO -24  -> 02fe
    LVO -30  -> 0302
    LVO -36  -> 0304
    LVO -42  -> 09f0
    LVO -48  -> 09fe
    LVO -54  -> 0f06
    LVO -60  -> 0f42
    LVO -66  -> 0f6c
    LVO -72  -> 1048
    LVO -78  -> 10ac
    LVO -84  -> 138c
    LVO -90  -> 1420
    LVO -96  -> 145a
    LVO -102 -> 1462
    LVO -108 -> 1478

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
