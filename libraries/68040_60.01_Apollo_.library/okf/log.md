---
type: Log
title: Work Log
description: Analysis sessions for 68040.library 60.01 (Apollo).
---

# Log

## 2026-10-10

- sha256 c9dc685ad64694c758327936940dd69426f98bc82c8302b315b51bafb5b7f932, 392 bytes.
- IRA disassembly (-M68040) into work/; decoded RomTag, AUTOINIT
  InitTable (dataSize 0x22), absolute-long func table (4 entries),
  old-style InitStruct data table.
- Identified as a loader stub: init only checks AttnFlags and opens
  "68o4o.library" (FPU40) or "68060.library"; no user LVOs.
- Reconstructed source/ (loader_lib.s header + loader.c + endmodule.s);
  `make` produces a valid single-hunk .library.
- Status: FULL.
