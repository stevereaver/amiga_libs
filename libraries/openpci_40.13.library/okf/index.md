---
type: Library
title: openpci_40.13.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:19.060713Z
---

# openpci_40.13.library

## Structure scan

```
romtag@4 flags=81 ver=40 type=9 pri=0
  name[36]='openpci.library' idstr[74]='openpci.library 40.13 (2.5.2026) (c) THOR' init=26 endskip=11c
  inittab: datasize=ac functab@c4 datatab@0 initfunc=11c
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
