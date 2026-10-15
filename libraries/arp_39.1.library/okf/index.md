---
type: Library
title: arp_39.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:09.808303Z
---

# arp_39.1.library

## Structure scan

```
romtag@4 flags=80 ver=39 type=9 pri=0
  name[4d]='arp.library' idstr[5a]='ArpLib 39.1 (cdh/sdb 4/9/89)\n' init=c0 endskip=1e
  inittab: datasize=7e functab@d0 datatab@1b0 initfunc=236
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
