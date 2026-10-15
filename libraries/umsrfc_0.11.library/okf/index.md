---
type: Library
title: umsrfc_0.11.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:23.794281Z
---

# umsrfc_0.11.library

## Structure scan

```
romtag@3a flags=00 ver=0 type=9 pri=0
  name[4]='umsrfc.library' idstr[13]='$VER: umsrfc.library 0.11 (9.12.95)\r\n' init=aa endskip=54
  inittab: datasize=48e72138 functab@2e0849f9 datatab@7ffe initfunc=294e8002

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
