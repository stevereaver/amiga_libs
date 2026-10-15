---
type: Library
title: sz_fio_mpeg_0.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:15.242856Z
---

# sz_fio_mpeg_0.1.library

## Structure scan

```
romtag@4 flags=80 ver=0 type=9 pri=0
  name[254]='sz_fio_mpeg.library' idstr[268]='$VER: sz_fio_mpeg  V0.1  05.03.2000  by Rainer Müller' init=1e endskip=146
  inittab: datasize=430 functab@2412 datatab@2e initfunc=4e
  functab: 8 vectors (abs-long)
    LVO -6   -> 006e
    LVO -12  -> 00b8
    LVO -18  -> 00ec
    LVO -24  -> 012c
    LVO -30  -> 245c
    LVO -36  -> 2474
    LVO -42  -> 2488
    LVO -48  -> 24a0

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
