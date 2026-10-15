---
type: Library
title: playsid_1.2.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:29.399561Z
---

# playsid_1.2.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='playsid.library' idstr[2e]='playsid.library 1.2 (30.03.96)\r\n' init=76 endskip=3630
  inittab: datasize=170 functab@86 datatab@e2 initfunc=102
  functab: 22 vectors (abs-long)
    LVO -6   -> 01aa
    LVO -12  -> 01fc
    LVO -18  -> 0214
    LVO -24  -> 025a
    LVO -30  -> 025e
    LVO -36  -> 02a0
    LVO -42  -> 0104
    LVO -48  -> 02f2
    LVO -54  -> 0318
    LVO -60  -> 036e
    LVO -66  -> 044e
    LVO -72  -> 048a
    LVO -78  -> 04b6
    LVO -84  -> 04fe
    LVO -90  -> 0532
    LVO -96  -> 02bc
    LVO -102 -> 02e8
    LVO -108 -> 02e2
    LVO -114 -> 02c2
    LVO -120 -> 02cc
    LVO -126 -> 02d2
    LVO -132 -> 02dc

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
