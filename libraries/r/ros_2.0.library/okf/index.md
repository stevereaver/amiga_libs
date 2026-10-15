---
type: Library
title: ros_2.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:13.927996Z
---

# ros_2.0.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[1e]='ros.library' idstr[2a]='ROS 2.0 (01.11.96) RETIRE Operating System - © 1995/96 by TIK/RETIRE\r\n' init=14e endskip=a02
  inittab: datasize=126 functab@15e datatab@212 initfunc=232
  functab: 44 vectors (abs-long)
    LVO -6   -> 02c6
    LVO -12  -> 07a0
    LVO -18  -> 099c
    LVO -24  -> 09fe
    LVO -30  -> 0eda
    LVO -36  -> 1288
    LVO -42  -> 18ce
    LVO -48  -> 18ee
    LVO -54  -> 1920
    LVO -60  -> 19a8
    LVO -66  -> 15a6
    LVO -72  -> 190e
    LVO -78  -> 281c
    LVO -84  -> 2a4c
    LVO -90  -> 2b54
    LVO -96  -> 275c
    LVO -102 -> 27aa
    LVO -108 -> 2560
    LVO -114 -> 2744
    LVO -120 -> 272c
    LVO -126 -> 2c0a
    LVO -132 -> 2da0
    LVO -138 -> 1a54
    LVO -144 -> 1a82
    LVO -150 -> 1a96
    LVO -156 -> 1be6
    LVO -162 -> 2e64
    LVO -168 -> 1bf0
    LVO -174 -> 1c62
    LVO -180 -> 1c9e
    LVO -186 -> 1e14
    LVO -192 -> 1ec2
    LVO -198 -> 1ef6
    LVO -204 -> 1f96
    LVO -210 -> 1fda
    LVO -216 -> 1fe2
    LVO -222 -> 20c2
    LVO -228 -> 2212
    LVO -234 -> 239c
    LVO -240 -> 24aa
    LVO -246 -> 20b2
    LVO -252 -> 2006
    LVO -258 -> 35cc
    LVO -264 -> 338e

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
