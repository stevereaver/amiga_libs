---
type: Library
title: mcpgfx_3.9.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:00.475596Z
---

# mcpgfx_3.9.library

## Structure scan

```
romtag@4 flags=80 ver=3 type=9 pri=0
  name[1e]='mcpgfx.library' idstr[30]='$VER: MCPgfx.library 3.9 (10.08.04) (c)2000-2001 by Dieter Groppé, (1995-1998 ALiENDESiGN)' init=8c endskip=3c7f
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
