---
type: Library
title: btree_53.6.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:17:06.814606Z
---

# btree_53.6.library

## Structure scan

```
romtag@d8 flags=80 ver=53 type=9 pri=0
  name[4]='btree.library' idstr[18]='btree.library 53.3 (6.9.2015) [OS3/m68k], Copyright (C) 2013-2015 Thore Böckelmann' init=c8 endskip=f2
  inittab: datasize=58 functab@6c datatab@0 initfunc=12a
  functab: 22 vectors (abs-long)
    LVO -6   -> 0410
    LVO -12  -> 0422
    LVO -18  -> 03f2
    LVO -24  -> 0450
    LVO -30  -> 0528
    LVO -36  -> 0696
    LVO -42  -> 06d0
    LVO -48  -> 0726
    LVO -54  -> 0750
    LVO -60  -> 0758
    LVO -66  -> 0760
    LVO -72  -> 0770
    LVO -78  -> 0780
    LVO -84  -> 078e
    LVO -90  -> 079c
    LVO -96  -> 07ac
    LVO -102 -> 07ea
    LVO -108 -> 0824
    LVO -114 -> 0868
    LVO -120 -> 0870
    LVO -126 -> 087e
    LVO -132 -> 089c

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
