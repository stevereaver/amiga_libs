---
type: Library
title: mcpgfx_3.7.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:01.155347Z
---

# mcpgfx_3.7.library

## Structure scan

```
romtag@4 flags=80 ver=3 type=9 pri=0
  name[1e]='mcpgfx.library' idstr[2e]='$VER: MCP-GFX Library 3.7 (05.07.98) (c)1995-1998 by ALiENDESiGN' init=70 endskip=3c97
  inittab: datasize=22 functab@80 datatab@ac initfunc=cc
  functab: 3 vectors (abs-long)
    LVO -6   -> 01ce
    LVO -12  -> 01dc
    LVO -18  -> 01ee

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
