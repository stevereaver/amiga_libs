---
type: Library
title: zlib.library 3.2
description: Amiga shared zlib library (gz-style API) by Achim Stegemann; hybrid m68k + WarpOS PPC build of zlib 1.1.4.
tags: [zlib, gzip, deflate, powerup, warpos, stormc]
timestamp: 2026-10-10T00:00:00Z
---

# zlib.library 3.2 — Knowledge Bundle

`binary/zlib_3.2.library` — `$VER: zlib.library 3.2 (11-Apr-03)`, 106,984 bytes,
Amiga loadseg hunk binary, 6 hunks. Byte-identical to Aminet
`util/libs/zlib-library.lha` v3.2 (Achim Stegemann), whose archive ships the
original StormC sources — recovered and placed in `source/`.

## Overview

Shared library exposing a gzip-file-oriented subset of zlib 1.1.4. Two complete
zlib builds coexist: m68k (hunk 0) serves the `GZ_*` LVOs; PowerPC/WarpOS
(hunks 1-2) serves the `PPCGZ_*` LVOs. 24 vectors: 4 system + 20 API
(10 68k + 10 PPC). Built with StormC4 GCC, `__MIXEDBINARY__`.

## Categories

- [functions/](functions/index.md) — all 24 LVO entries resolved
- [structures/](structures/index.md) — ZLibBase, gz_stream, hunk map, init table
- [algorithms/](algorithms/index.md) — zlib core notes
- [findings/](findings/index.md) — inconsistencies & open questions
- [log.md](log.md) — work journal
