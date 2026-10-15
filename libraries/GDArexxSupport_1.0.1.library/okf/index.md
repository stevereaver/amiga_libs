---
type: Library
title: GDArexxSupport_1.0.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:25.503206Z
---

# GDArexxSupport_1.0.1.library

## Structure scan

```
romtag@3dc flags=80 ver=1 type=9 pri=0
  name[28]='2<ÿ|`H2<ÿj`B2<þz`<2<þt`62<þn`02<þb`*2<þ\x80`$2<ÿL`\x1er\x88`\x1a2<ÿ\x16`\x14r\x9a`\x102<ÿ"`\n2<ÿ\x1c`\x042<ÿXLï\x03' idstr[3f]='62<þn`02<þb`*2<þ\x80`$2<ÿL`\x1er\x88`\x1a2<ÿ\x16`\x14r\x9a`\x102<ÿ"`\n2<ÿ\x1c`\x042<ÿXLï\x03' init=18 endskip=3f6
  inittab: datasize=ff34605a functab@323cfe68 datatab@6054323c initfunc=ff70604e

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
