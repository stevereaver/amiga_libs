---
type: Structure
title: InitTable / hunk map
description: Resident header layout of the single CODE hunk.
timestamp: 2026-10-10T22:00:00Z
---

# InitTable / hunk map

Single CODE hunk (0xe4 bytes).  Memory offsets from hunk start:

| off  | contents |
|------|----------|
| 0x00 | `moveq #-1,d0; rts` loader entry |
| 0x04 | RomTag: 0x4afc, matchtag→self, endskip→0xe2, RTF_AUTOINIT, ver 47, NT_LIBRARY, pri 0, name→0x1e, id→0x2e, init→0x4a |
| 0x1e | `version.library\0` |
| 0x2e | `version 47.3 (13.7.2021)\r\n\0` (+pad) |
| 0x4a | InitTable: dataSize 0x2a, functab→0x5a, dataTable 0, initFunc→0x66 |
| 0x5a | functab: -1, +0x20 Open, +0x2e Close, +0x40 Expunge, +0x84 ExtFunc, -1 |
| 0x66 | initFunc: exg d0,a5; a6→0x22, a0→0x26, lib_Revision=3; exg; rts |
| 0x7a | Open / 0xa8 Close / 0xba Expunge+tail / 0xfe ExtFunc stub |
| 0xe2 | EndSkip `.word 0` |

Identical to the 47.2 build apart from the idstring and the
`lib_Revision = 3` immediate.
