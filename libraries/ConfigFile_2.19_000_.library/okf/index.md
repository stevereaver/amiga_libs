---
type: Library
title: ConfigFile_2.19(000).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:05.532890Z
---

# ConfigFile_2.19(000).library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=100
  name[6f]='configfile.library' idstr[25]='ConfigFile.library 2.19 (1.10.97) ©1996-1997 Marcel Karas, 68000 version.' init=f0 endskip=1e
  inittab: datasize=8ad0003 functab@e5340 datatab@66182c6c initfunc=7004

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
