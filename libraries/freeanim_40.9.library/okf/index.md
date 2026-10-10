---
type: Library
title: freeanim.library 40.9
description: Functional AUTOINIT library with only the four system vectors — no public API.
tags: [autoinit]
---

# freeanim.library 40.9 — Knowledge Bundle

## Overview

Binary: `binary/freeanim_40.9.library`, 396 bytes,
SHA256 `24feed8924d51816636b0d445558f12dfbd6eef5f88c77d31fb5e9e6ff729910`.
ID string `freeanim.library 40.9 (11.8.95)` (no `$VER:` prefix).

Single code hunk, RomTag `RTF_AUTOINIT|RTF_COLDSTART`, version 40,
NT_LIBRARY, priority 0.  AUTOINIT function table holds only the four
mandatory system vectors; LVO -24 lands on a shared
`moveq #0,rts` stub.  There is no public API in this build.

Unlike the stub-only 40.29, this build has a working lifecycle:
init stores the segment list at +0x22 (dataSize 0x26), Open bumps
lib_OpenCnt, Close performs a guarded decrement and honours
LIBF_DELEXP, Expunge removes/frees via exec.

Reconstructed in `source/`; `make` produces a valid HUNK `.library`.

## Categories

- [functions/](functions/index.md) — LVO entries
- [structures/](structures/index.md) — hunk map, RomTag/InitTable, base layout
- [findings/](findings/index.md) — quirks and version differences
- [log.md](log.md) — work journal
