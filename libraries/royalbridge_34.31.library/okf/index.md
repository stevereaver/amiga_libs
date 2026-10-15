---
type: Library
title: royalbridge.library 34.31 (31 Oct 1998)
description: >-
  "Royal Bridge Library" by Ivan Sturlic - an ARexx bridge:
  exports RBCALL/RBSET/RBGET-style vectors that let C programs
  load and invoke .rb bridge modules via rexxsyslib.library.
timestamp: 2026-10-15T08:50:00Z
---

# royalbridge.library 34.31

ARexx<->C bridge.  Opens `rexxsyslib.library` + `dos.library`, loads
`royalbridge:.rb` bridge files, exposes a `RB*` API (embedded names:
RBCALL, RBCOPYSTR, RBSET, RBGET, RBSTRLEN, RBNEWSTR, RBFREESTR,
RBGETSTR, RBLOADRB) plus error tags ERR_OPENLIB/ERR_LOADRB/
ERR_FINDFUNC and a "%ld" formatting table.

## Status

FULL - byte-identical rebuild (source/h0.s+h1.s + fixup.py).

## Contents

- [functions/](functions/index.md) - [structures/](structures/index.md)
- [findings/](findings/index.md) - [log.md](log.md)
