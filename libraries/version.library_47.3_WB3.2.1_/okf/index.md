---
type: Library
title: version.library 47.3 (13.7.2021) — Workbench 3.2.1
description: >-
  OS3.2.1 version.library: no public API, four system vectors
  with textbook DELEXP semantics — byte-layout identical to the
  47.2 build except the idstring and lib_Revision = 3.
timestamp: 2026-10-10T22:00:00Z
---

# version.library 47.3 (13.7.2021)

Single-hunk AUTOINIT library shipped with Workbench 3.2.1.  It
exports no user functions — the vector table carries only
Open/Close/Expunge/ExtFunc — and exists to be found by
`FindResident`/`version` queries and to satisfy
`OpenLibrary("version.library", …)` version checks.

## Binary facts

- sha256 `7b2f66e8bd1ea7c7e1493cb5f41a2f6ad75fdee650c3d53c167f22dbba41ea50`, 308 bytes
- hunks: single CODE hunk 0xe4 bytes
- RomTag: RTF_AUTOINIT, RT_VERSION 47, NT_LIBRARY, pri 0
- idstring: `version 47.3 (13.7.2021)\r\n`
- InitTable dataSize 0x2a (compact base: SysBase + seglist only)
- word-offset functab, leading + trailing -1 markers:
  Open +0x20, Close +0x2e, Expunge +0x40, ExtFunc +0x84
- init writes `lib_Revision = 3`; EndSkip = last word of hunk
- hunk trailer: RELOC32 (7 entries) + HUNK_END
- **byte-identical to the 47.2 build except**: idstring
  (`47.2 (10.4.2021)` → `47.3 (13.7.2021)`) and the init
  immediate `lib_Revision = 2 → 3`.

## Status

FULL — reconstructed in C (`source/`), builds with
m68k-amigaos-gcc -m68000 via the two-pass genfunctab link.
Semantics verified against IRA disassembly of the original.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
