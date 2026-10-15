---
type: Library
title: pci_9.9.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:25.136748Z
---

# pci_9.9.library

## Structure scan

```
romtag@4 flags=00 ver=9 type=9 pri=0
  name[1e]='pci.library' idstr[30]='pci.library 9.9 (29 NOV 13) written by Pawel Stypula and copyright (c) 2000-2013 ELBOX COMPUTER, all rights reserved.\n' init=d0 endskip=2d12
  inittab: datasize=48e770ee functab@2c780004 datatab@612a4a80 initfunc=6720243c

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
