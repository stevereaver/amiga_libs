---
type: Library
title: freeanim.library 40.29
description: AUTOINIT stub library — every vector and the init routine are a single "return 0".
tags: [stub, autoinit]
---

# freeanim.library 40.29 — Knowledge Bundle

## Overview

Binary: `binary/freeanim_40.29.library`, 188 bytes,
SHA256 `a9d8665b98a5d1212e6d96fd278e89818640d61e06803803d84e10c0238f8b72`.
ID string `freeanim 40.29 (1.4.94)` (no `$VER:` prefix, unlike the
$VER:-style string found in v40.9).

Single code hunk, one RomTag (`RTF_AUTOINIT`, version 40, NT_LIBRARY,
priority 0).  The AUTOINIT table contains only the four mandatory
system vectors (-6/-12/-18/-24); there are no public API vectors.
All four entries, and the InitTable init routine, point at the same
`moveq #0,d0 / rts` at code+0x66.  InitTable dataSize is 0x2a
(Library + 2 unused longs); there is no InitStruct data table.

Reconstructed in `source/` (asm RomTag + C stub, two-pass generated
function table).  `make` produces a valid HUNK `.library`.

## Categories

- [functions/](functions/index.md) — LVO entries
- [structures/](structures/index.md) — hunk map, RomTag/InitTable, base layout
- [findings/](findings/index.md) — quirks and open questions
- [log.md](log.md) — work journal
