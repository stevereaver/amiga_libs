---
type: Library
title: requester_1.6.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:17.654661Z
---

# requester_1.6.library

## Structure scan

```
romtag@4 flags=00 ver=1 type=9 pri=0
  name[24bb]='requester.library' idstr[24cd]='dissidents RequesterLib 1.6 (Mar 1, 90)\r\n' init=13a endskip=1e
  inittab: datasize=2f0a45fa functab@1b062548 datatab@44c254e initfunc=2a843fa

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
