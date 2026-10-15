---
type: Library
title: xpkRAKE_1.5(020).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:48.597653Z
---

# xpkRAKE_1.5(020).library

## Structure scan

```
romtag@10 flags=80 ver=1 type=9 pri=0
  name[2a]='xpkRAKE.library' idstr[3a]='xpkRAKE.library Version 1.5(18 Jan 95) © Karsten Dageförde' init=78 endskip=1ac2
  inittab: datasize=2a functab@88 datatab@b4 initfunc=d4
  functab: 10 vectors (abs-long)
    LVO -6   -> 035c
    LVO -12  -> 036a
    LVO -18  -> 037e
    LVO -24  -> 03b6
    LVO -30  -> 0240
    LVO -36  -> 0246
    LVO -42  -> 02ee
    LVO -48  -> 0334
    LVO -54  -> 0336
    LVO -60  -> 035a

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
