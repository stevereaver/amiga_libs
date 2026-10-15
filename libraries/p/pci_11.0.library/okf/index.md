---
type: Library
title: pci_11.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:27.846080Z
---

# pci_11.0.library

## Structure scan

```
romtag@4 flags=00 ver=11 type=9 pri=0
  name[1e]='pci.library' idstr[30]='pci.library 11.0 (28 JUN 16) written by Pawel Stypula and copyright (c) 2000-2016 ELBOX COMPUTER, all rights reserved.\n' init=d0 endskip=2de2
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
