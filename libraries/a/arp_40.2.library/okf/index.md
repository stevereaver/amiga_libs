---
type: Library
title: arp_40.2.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:30.955095Z
---

# arp_40.2.library

## Structure scan

```
romtag@4 flags=80 ver=40 type=9 pri=0
  name[4d]='arp.library' idstr[5a]='Arp 40.2 (7.2.93)\n' init=b4 endskip=1e
  inittab: datasize=7e functab@c4 datatab@1a4 initfunc=22a
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
