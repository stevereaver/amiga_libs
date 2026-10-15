---
type: Library
title: sos_2.6R13.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:46.361922Z
---

# sos_2.6R13.library

## Structure scan

```
romtag@4 flags=00 ver=1 type=9 pri=0
  name[1e]='sos.library' idstr[2a]='SOS.lib  (c) 1992/93 by Dierk Ohlerich ---\nSanity Operating System Library Version\n\n' init=80 endskip=38ec
  inittab: datasize=48e70006 functab@4bfa2c4e datatab@2b480022 initfunc=1b7c0009

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
