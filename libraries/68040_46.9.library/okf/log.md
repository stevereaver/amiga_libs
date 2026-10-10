---
type: Log
title: Work Log
description: Analysis sessions for 68040.library 46.9 (Lynxx).
---

# Log

## 2026-10-10

- sha256 f55838ca8367a4a46d7dd964a11b9d0f4db0f4481e0dc2ff52bb1564a4f538c1, 568 bytes.
- IRA disassembly (-M68040) into work/; decoded RomTag (ver 46),
  AUTOINIT InitTable (dataSize 0x34), absolute-long func table
  (4 entries, Close=Expunge=ExtFunc same stub).
- Identified: loader stub; exec LVO -810 (TaggedOpenLibrary) for a
  DOS base, movec-pcr Supervisor probe for 060 detection,
  OpenLibrary("060.library") forwarding on 060, LoadSeg+InitResident
  preload attempt on real 040 (name pointer +2 quirk — dead code).
- Reconstructed source/ (loader_lib.s + loader.c + helpers.s +
  endmodule.s); `make` builds a valid single-hunk .library.
- Status: FULL.
