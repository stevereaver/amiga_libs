---
type: Library
title: prelude_4.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:24.594783Z
---

# prelude_4.0.library

## Structure scan

```
romtag@774 flags=80 ver=4 type=9 pri=0
  name[710]='prelude.library' idstr[720]='prelude.library 4.0 (22.05.2023)' init=4 endskip=78e
  inittab: datasize=7564652f functab@436c6173 datatab@7369634f initfunc=6e6c7900

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
