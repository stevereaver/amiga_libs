---
type: Library
title: asdg-low-mem.library 0.0 (10-Jun-87)
description: >-
  ASDG low-memory alert server by Perry S. Kivolowitz (1987): client
  processes register a named port plus a LowMemMsg; when the low-memory
  alert fires the library re-sends each message so clients are woken
  without needing a reply port of their own.
timestamp: 2026-10-10T19:00:00Z
---

# asdg-low-mem.library 0.0 (10-Jun-87)

ASDG low memory alert server.  A client registers a public message
port name and a `LowMemMsg` (`struct Message` + `LONG lm_flag`) with
`RegLowMemReq`.  The library's Expunge vector is repurposed as the
alert trigger: when exec calls it, every registered message whose
`lm_flag` is still `LM_CONDITION_ACKNOWLEDGED` ('ASDG') is cleared to
`LM_LOW_MEMORY_CONDITION` (0), re-initialised and `PutMsg()`ed to the
client's port.

## Binary facts

- sha256 `d9b6df26368c8960bcc6f11a2f8e0d276a625a1708a4df4266626b2d062e5c52`, 900 bytes
- hunks: single CODE hunk 0x2ec (748) bytes; empty .data/.bss hunks
- RomTag: RTF_AUTOINIT, version 0, NT_LIBRARY, pri 0
- idstring: `asdg low memory alert server (10-Jun-87)\r\n`
- embedded copyright: `Copyright 1987 By ASDG Incorporated` /
  `Perry S. Kivolowitz`
- InitTable dataSize 0x3c; InitStruct data table present; function
  table in absolute-longword form (-1L terminated)
- 7 vectors: Open, Close, Expunge, module entry (-24), RegLowMemReq
  (-30), DeRegLowMemReq (-36), query (-42)

## Status

Byte-identical.  `make` assembles `source/asdg_h0.s` (verbatim asm,
all seven vectors) and `fixup.py` rewrites the linked single-hunk
file into the original 3-hunk envelope (CODE + empty DATA + empty
BSS).  `md5 45764a4e4bcd377c3c1bf02d4b71a69f`.  `make cmodel`
builds the earlier C reconstruction for reference.
Runtime-verified: `work/oracle.py` traces init/Open/Close/Reg/
DeReg/query plus the -18 alert trigger and the immediate expunge
at private-count 0 -- original vs rebuild logs identical.

Note: `libraries/asdg-low-mem_10-jun-87_.library` is byte-identical
(same sha256) -- see findings/VersionPair.md.

## Contents

- [functions/](functions/index.md) — one concept per LVO (-6 .. -42)
- [structures/](structures/index.md) — LowMemBase, RegNode, InitTable
- [findings/](findings/index.md) — quirks and deviations
- [log.md](log.md) — work journal
