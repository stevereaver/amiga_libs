---
type: Library
title: icon_46.4.332(020).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:37.911954Z
---

# icon_46.4.332(020).library

## Structure scan

```
romtag@2 flags=80 ver=46 type=9 pri=136
  name[2a4]='icon.library' idstr[2b6]='icon.library 46.4.332 (68020)' init=1c endskip=7394
  inittab: datasize=2710 functab@2c datatab@72 initfunc=7c
  functab: 0 vectors (abs-long)

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
