---
type: Library
title: parm_4.7.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:47.379574Z
---

# parm_4.7.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[0]='p' idstr[d]='\x1e\x80\x04\t' init=b4 endskip=1e
  inittab: datasize=14357c functab@70016 datatab@41ec800f initfunc=25480018

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
