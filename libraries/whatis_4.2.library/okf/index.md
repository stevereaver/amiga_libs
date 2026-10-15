---
type: Library
title: whatis_4.2.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:29.207665Z
---

# whatis_4.2.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[6b]='&B\xad' idstr[23]='\x0c"\x080|' init=4c endskip=1e
  inittab: datasize=e43ed functab@1432fc datatab@432fc initfunc=241ec

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
