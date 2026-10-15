---
type: Library
title: rexxplslib_1.Q199310230407.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:26.968462Z
---

# rexxplslib_1.Q199310230407.library

## Structure scan

```
romtag@10 flags=80 ver=1 type=9 pri=0
  name[23f]='rexxplslib.library' idstr[267]='RexxPlsLib V1.Q199310230407\r\n' init=2c endskip=160e
  inittab: datasize=1be functab@6c datatab@ac initfunc=2dc
  functab: 15 vectors (abs-long)
    LVO -6   -> 0d8c
    LVO -12  -> 0d94
    LVO -18  -> 0da2
    LVO -24  -> 0df8
    LVO -30  -> 156a
    LVO -36  -> 164a
    LVO -42  -> 0dfc
    LVO -48  -> 18ec
    LVO -54  -> 6598
    LVO -60  -> 6788
    LVO -66  -> 27ce
    LVO -72  -> 2b60
    LVO -78  -> 4138
    LVO -84  -> 6232
    LVO -90  -> 5e52

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
