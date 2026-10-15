---
type: Library
title: multireq_1.20.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:18.331689Z
---

# multireq_1.20.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='multireq.library' idstr[30]='MultiReq  1.20 (11-Nov-92) (c) 1992 by Andreas Krebs\r\n' init=aa endskip=240
  inittab: datasize=28 functab@ba datatab@112 initfunc=13e
  functab: 4 vectors (abs-long)
    LVO -6   -> 01aa
    LVO -12  -> 01b8
    LVO -18  -> 01cc
    LVO -24  -> 023c

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
