---
type: Library
title: boards.library 1.0
description: Richard Körber's replacement for Torsten Bach's boards.library; relays to expname.library.
tags: [autoinit, boards]
---

# boards.library 1.0 — Knowledge Bundle

## Overview

Binary: `binary/boards_1.0.library`, 592 bytes,
SHA256 `0b77168ddeec3be45f1cca9ba81526ce0080d86c10234336a36817424835131a`.
ID string `boards.library 1.0 (14.4.96)` (no `$VER:`); embedded
copyright `boards.library V1.0  Replaces boards.library by Torsten
Bach    (C) 1995-96 Richard Körber     e-mail: shred@tfh.dssd.sub.org`.

Single code hunk, RomTag `RTF_AUTOINIT`, version 1, NT_LIBRARY.
Function table uses ABSOLUTE LONG entries (not word offsets):
Open, Close, Expunge, reserved stub, and one public vector (-30).

Init opens `"expname.library"` v1 (Körber's expansion-name helper
library) into a code-hunk cell; init fails if it is not installed.
The public vector calls expname.library's own LVO -30 and returns
the bitwise complement of its result — semantics of that function
are inferred (no FD/LVO file for boards.library was found).

Reconstructed in `source/`; `make` produces a valid HUNK `.library`.

## Categories

- [functions/](functions/index.md) — LVO entries
- [structures/](structures/index.md) — hunk map, RomTag/InitTable, base layout
- [findings/](findings/index.md) — quirks and open questions
- [log.md](log.md) — work journal
