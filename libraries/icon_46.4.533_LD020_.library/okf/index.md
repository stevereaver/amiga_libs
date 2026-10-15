---
type: Library
title: icon_46.4.533(LD020).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:52.817466Z
---

# icon_46.4.533(LD020).library

## Structure scan

```
romtag@2 flags=80 ver=46 type=9 pri=136
  name[322]='icon.library' idstr[334]='icon.library 46.4.533 (LD020)' init=1c endskip=7ea8
  inittab: datasize=2710 functab@2c datatab@74 initfunc=7e
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
