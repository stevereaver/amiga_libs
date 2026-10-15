---
type: Library
title: datatypes_45.4.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:26.285765Z
---

# datatypes_45.4.library

## Structure scan

```
romtag@4 flags=80 ver=45 type=9 pri=0
  name[200]='' idstr[218]='.library' init=23c endskip=1e
  inittab: datasize=69622e6c functab@69627261 datatab@72790000 initfunc=6f626a65

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
