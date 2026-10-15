---
type: Library
title: datatypes_45.3.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:25.271514Z
---

# datatypes_45.3.library

## Structure scan

```
romtag@4 flags=80 ver=45 type=9 pri=0
  name[200]='intuition.library' idstr[218]='ibrary' init=23c endskip=1e
  inittab: datasize=2e6c6962 functab@72617279 datatab@6f62 initfunc=6a656374

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
