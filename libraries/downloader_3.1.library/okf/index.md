---
type: Library
title: downloader_3.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:58.430085Z
---

# downloader_3.1.library

## Structure scan

```
romtag@4 flags=80 ver=3 type=9 pri=0
  name[1e]='downloader.library' idstr[31]='$VER: downloader.library 3.1 (19.10.93)\n' init=7c endskip=134
  inittab: datasize=38 functab@8c datatab@a8 initfunc=134
  functab: 6 vectors (abs-long)
    LVO -6   -> 00c8
    LVO -12  -> 00d6
    LVO -18  -> 00ec
    LVO -24  -> 0130
    LVO -30  -> 0204
    LVO -36  -> 0130

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
