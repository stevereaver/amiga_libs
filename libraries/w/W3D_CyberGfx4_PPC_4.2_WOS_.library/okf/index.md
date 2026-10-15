---
type: Library
title: W3D_CyberGfx4_PPC_4.2(WOS).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:02.278393Z
---

# W3D_CyberGfx4_PPC_4.2(WOS).library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[238]='\x80' idstr[252]='g\x06p÷,_Nup' init=1e endskip=4e
  inittab: datasize=22 functab@1f8 datatab@2e initfunc=50
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
