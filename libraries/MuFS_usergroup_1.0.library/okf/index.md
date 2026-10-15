---
type: Library
title: MuFS_usergroup_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:35.318364Z
---

# MuFS_usergroup_1.0.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[b0]='ÿ:+@' idstr[c4]='S\x87dú \rLßl\x80PONu\x9eü' init=4 endskip=1e
  inittab: datasize=4afc0000 functab@40000 datatab@1e8004 initfunc=9000000

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
