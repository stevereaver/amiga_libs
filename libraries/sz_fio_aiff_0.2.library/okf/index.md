---
type: Library
title: sz_fio_aiff_0.2.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:28.904513Z
---

# sz_fio_aiff_0.2.library

## Structure scan

```
romtag@4 flags=80 ver=0 type=9 pri=0
  name[254]='sz_fio_aiff.library' idstr[268]='$VER: sz_fio_aiff V0.2  13.03.2000  by Rainer Müller' init=1e endskip=146
  inittab: datasize=430 functab@49bc datatab@2e initfunc=4e
  functab: 12 vectors (abs-long)
    LVO -6   -> 006e
    LVO -12  -> 00b8
    LVO -18  -> 00ec
    LVO -24  -> 012c
    LVO -30  -> 4a16
    LVO -36  -> 4a2e
    LVO -42  -> 4a42
    LVO -48  -> 4a5a
    LVO -54  -> 4a76
    LVO -60  -> 4a92
    LVO -66  -> 4aac
    LVO -72  -> 4ac4

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
