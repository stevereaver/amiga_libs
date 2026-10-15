---
type: Library
title: mcpgfx_4.4.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:02.618117Z
---

# mcpgfx_4.4.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[1e]='mcpgfx.library' idstr[30]='$VER: MCPgfx.library 4.4 (14.04.08) (c)2000-2008 by Dieter Groppé, (1995-1998 ALiENDESiGN)' init=8c endskip=3cdf
  inittab: datasize=22 functab@9c datatab@c8 initfunc=e8
  functab: 3 vectors (abs-long)
    LVO -6   -> 01ee
    LVO -12  -> 01fc
    LVO -18  -> 020e

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
