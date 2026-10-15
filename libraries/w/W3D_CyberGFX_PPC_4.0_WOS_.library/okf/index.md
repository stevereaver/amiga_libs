---
type: Library
title: W3D_CyberGFX_PPC_4.0(WOS).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:11.372802Z
---

# W3D_CyberGFX_PPC_4.0(WOS).library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[18c]='/\x0eJ¹' idstr[1a6]='' init=1e endskip=4e
  inittab: datasize=22 functab@150 datatab@2e initfunc=50
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
