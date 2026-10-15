---
type: Library
title: version.library 47.2 (10.4.2021) — Workbench 3.2
description: >-
  OS3.2 version.library: no public API, four system vectors with
  textbook DELEXP semantics — a semantic reversion from the
  unconditional-close quirk of the 39/40.x line and without the
  hidden-semaphore fields of the 44.x/45.x line.
timestamp: 2026-10-10T21:55:00Z
---

# version.library 47.2 (10.4.2021)

Single-hunk AUTOINIT library shipped with Workbench 3.2.  It
exports no user functions — the vector table carries only
Open/Close/Expunge/ExtFunc — and exists to be found by
`FindResident`/`version` queries and to satisfy
`OpenLibrary("version.library", …)` version checks.

## Binary facts

- sha256 `23501aa2cceef70ad179e4347ebb290cc3e229e65b9c0cc16b450b47244bebd3`, 308 bytes
- hunks: single CODE hunk 0xe4 bytes
- RomTag: RTF_AUTOINIT, RT_VERSION 47, NT_LIBRARY, pri 0
- idstring: `version 47.2 (10.4.2021)\r\n`
- InitTable dataSize 0x2a (compact base: SysBase + seglist only)
- word-offset functab, leading + trailing -1 markers:
  Open +0x20, Close +0x2e, Expunge +0x40, ExtFunc +0x84
- init writes `lib_Revision = 2`; EndSkip = last word of hunk
- hunk trailer: 1 data hunk? — no, code only; RELOC32 table of
  7 entries then HUNK_END

## Status

FULL — `source/version.s` rebuilds the binary **byte-identically**
(`make`); the earlier C model remains buildable via `make cmodel`.
machine68k oracle: init/open/close/expunge/deferred-expunge/stub
traces identical to the original.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
