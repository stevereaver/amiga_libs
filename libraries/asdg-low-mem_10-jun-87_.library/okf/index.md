---
type: Library
title: asdg-low-mem.library (10-Jun-87)
description: >-
  ASDG low-memory alert server by Perry S. Kivolowitz (1987): client
  processes register a named port plus a LowMemMsg; the Expunge vector
  is the alert trigger that re-sends each registered message.
timestamp: 2026-10-10T19:00:00Z
---

# asdg-low-mem.library (10-Jun-87)

Identical twin of `asdg-low-mem_0.0.library` — same sha256
(`d9b6df26...`), see findings/VersionPair.md.  ASDG low memory alert
server: clients register a public port name and a `LowMemMsg`; the
repurposed Expunge vector re-initialises and `PutMsg()`es each
registered message whose `lm_flag` is still 'ASDG'.

## Binary facts

- sha256 `d9b6df26368c8960bcc6f11a2f8e0d276a625a1708a4df4266626b2d062e5c52`, 900 bytes
- hunks: single CODE hunk 0x2ec bytes; empty .data/.bss
- RomTag: RTF_AUTOINIT, version 0, NT_LIBRARY, pri 0
- idstring: `asdg low memory alert server (10-Jun-87)\r\n`
- InitTable dataSize 0x3c, InitStruct data table, absolute-longword
  function table
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

## Contents

- [functions/](functions/index.md) — one concept per LVO (-6 .. -42)
- [structures/](structures/index.md) — LowMemBase, RegNode, InitTable
- [findings/](findings/index.md) — quirks and deviations
- [log.md](log.md) — work journal
