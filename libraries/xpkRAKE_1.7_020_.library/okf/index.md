---
type: Library
title: xpkRAKE_1.7(020).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:48:54.958840Z
---

# xpkRAKE_1.7(020).library

## Structure scan

```
romtag@10 flags=80 ver=1 type=9 pri=0
  name[2a]='xpkRAKE.library' idstr[3a]='xpkRAKE.library Version 1.7(6 Sep 95) © Karsten Dageförde' init=74 endskip=1b12
  inittab: datasize=2a functab@84 datatab@b0 initfunc=d0
  functab: 10 vectors (abs-long)
    LVO -6   -> 0380
    LVO -12  -> 038e
    LVO -18  -> 03a2
    LVO -24  -> 03da
    LVO -30  -> 023c
    LVO -36  -> 0242
    LVO -42  -> 02fe
    LVO -48  -> 0344
    LVO -54  -> 0346
    LVO -60  -> 037e

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
