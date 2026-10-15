---
type: Library
title: fantasia.library 1.0
description: Joystick decoder library — reads JOY1DAT/POTGOR/CIAA hardware registers directly.
tags: [autoinit, joystick, hardware]
---

# fantasia.library 1.0 — Knowledge Bundle

## Overview

Binary: `binary/fantasia_1.0.library`, 804 bytes,
SHA256 `89d1aede3018e1b04dc8ce952c523454fd835e34bc6f6e229a752f96f7d4d05f`.
ID string `fantasia.library 1.0` (LF-terminated, no `$VER:`).

Single code hunk, RomTag `RTF_AUTOINIT`, version 1, NT_LIBRARY.
Absolute-long function table: Open, Close, Expunge, reserved stub,
plus two joystick functions at -30/-36 which decode the JOY1DAT
quadrature counter and the CIAA/POTGOR button lines of joystick
port 1, returning direction/button indices in d3/d2 (not d0).

Init stores ExecBase (+0x22), opens dos.library v1 (+0x26), stores
the segment list (+0x2a); a private flag byte at +0x2e bit 3 carries
the deferred-expunge request.

Reconstructed in `source/`; `make` produces a **byte-identical**
`.library` (md5 `94eea1187a2d3fe15d2130c597f2897f`, 804B) via
verbatim asm `source/fantasia_v.s`.  The earlier C model remains as
`make cmodel`.  machine68k oracle (`work/oracle.py`) is
trace-identical over init, open, all JOY1DAT/POTGOR/CIAA decode
cases (9 directions + 5 button combos), the deferred+real expunge
paths, and the a5-flag defect.

## Categories

- [functions/](functions/index.md) — LVO entries
- [structures/](structures/index.md) — hunk map, RomTag/InitTable, base layout
- [findings/](findings/index.md) — quirks, bugs and open questions
- [log.md](log.md) — work journal
