---
type: Library
title: cachemap.library 34.5 (10.3.92)
description: >-
  "CacheMap" node allocator: each node carries a small caller-defined
  data area plus an embedded struct BitMap whose plane buffers are
  allocated and owned by the library.
timestamp: 2026-10-10T19:30:00Z
---

# cachemap.library 34.5 (10.3.92)

Third-party utility library that allocates "cache map" nodes: a list
node + a caller-sized data area + an embedded `struct BitMap` whose
`depth` plane buffers (BytesPerRow*Rows each) are allocated by the
library.  Nodes sit on a private list in the library base; graphics
is opened at init purely for `InitBitMap`.

## Binary facts

- sha256 `a9c68c0f089da8c82ec3eed6a41bf3f3fa0ca089c674417c2ac1b2101903973e`, 1004 bytes
- hunks: single CODE hunk 0x39c (924) bytes
- RomTag: RTF_AUTOINIT, version 34, NT_LIBRARY, pri 0
- idstring: `CacheMap 34.5 (10.3.92)\r\n`
- InitTable dataSize 0x3c, no InitStruct data (init code writes
  version 34 / revision 5 itself), word-offset function table
  (-1W marker, -1W terminator)
- 12 vectors: Open, Close, Expunge, module entry (-24), then 8 user
  functions -30 .. -72

## Status

**BYTE-IDENTICAL** — `source/cachemap_h0.s` (GNU as, verbatim
m68k) rebuilds the 1004-byte file exactly
(md5 `1a9165093434b519704ce0940ec2b912`); GNU ld emits the single
ascending RELOC32 group `6,a,12,16,1a,22,2a` on its own, so no
fixup pass is needed.  `make` verifies with `cmp`; the earlier C
model survives under `make cmodel`.  Runtime-identical under the
machine68k oracle (`work/oracle.py`): all 12 vectors exercised
incl. misaligned/failed CreateMap, LockMap NULL-plane quirk,
FillMapPlanes patterns + NULL-plane skip, six ScaleBits ratios,
plane-leak expunge and real teardown — original and rebuild logs
diff clean.  Function names are reconstructed — the binary ships
no fd and no exported names.

## Contents

- [functions/](functions/index.md) — one concept per LVO (-6 .. -72)
- [structures/](structures/index.md) — CacheMapBase, CacheNode, InitTable
- [findings/](findings/index.md) — quirks (expunge leaks nodes etc.)
- [log.md](log.md) — work journal
