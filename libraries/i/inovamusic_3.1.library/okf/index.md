---
type: Library
title: inovamusic_3.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:28:03.314913Z
---

# inovamusic_3.1.library

## Structure scan

```
romtag@4 flags=80 ver=3 type=9 pri=0
  name[1e]='inovamusic.library' idstr[31]='INOVAMusic Library 3.1 (8 June 1993) by Carl W. Moore\r\n' init=6c endskip=5aa
  inittab: datasize=4a functab@7c datatab@f0 initfunc=110
  functab: 3 vectors (abs-long)
    LVO -6   -> 01f2
    LVO -12  -> 0220
    LVO -18  -> 0244

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
