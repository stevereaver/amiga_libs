---
type: Library
title: btree_53.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:17:06.465542Z
---

# btree_53.1.library

## Structure scan

```
romtag@d2 flags=80 ver=53 type=9 pri=0
  name[4]='btree.library' idstr[18]='btree.library 53.1 (6.6.2013) [OS3/m68k], Copyright (c) 2013 Thore Böckelmann' init=c2 endskip=ec
  inittab: datasize=58 functab@66 datatab@0 initfunc=124
  functab: 22 vectors (abs-long)
    LVO -6   -> 040a
    LVO -12  -> 041c
    LVO -18  -> 03ec
    LVO -24  -> 044a
    LVO -30  -> 0520
    LVO -36  -> 068e
    LVO -42  -> 06c8
    LVO -48  -> 071e
    LVO -54  -> 0748
    LVO -60  -> 0750
    LVO -66  -> 0758
    LVO -72  -> 0768
    LVO -78  -> 0778
    LVO -84  -> 0786
    LVO -90  -> 0794
    LVO -96  -> 07a4
    LVO -102 -> 07e2
    LVO -108 -> 081c
    LVO -114 -> 0860
    LVO -120 -> 0868
    LVO -126 -> 0876
    LVO -132 -> 0894

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
