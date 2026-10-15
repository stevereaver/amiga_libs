---
type: Library
title: RexxConfigFile_1.1(000).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:53.720212Z
---

# RexxConfigFile_1.1(000).library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=100
  name[6d]='rexxconfigfile.library' idstr[25]='RexxConfigFile.library 1.1 (1.10.97) ©1997 Marcel Karas, 68000 version.' init=2c endskip=1e
  inittab: datasize=66696746 functab@696c652e datatab@6c696272 initfunc=61727920

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
