---
type: Log
title: Work Log
description: Analysis sessions for the Phase5 68040.library 46.5 loader.
---

# Log

## 2026-10-10

- sha256 23882a06695ab3dc18a3a262307b12c57428ffd2a685d9307535612e2a21f118, 748 bytes.
- IRA disassembly (-M68040) into work/; decoded RomTag (ver 46),
  AUTOINIT InitTable (dataSize 0x38), absolute-long func table
  (4 entries, three separate null stubs).
- Identified: Phase5 loader — dos.library open, AFB_68040 gate,
  movec-pcr Supervisor probe for 060 detection, OpenLibrary
  forwarding to "68060.library" on 060; LoadSeg+InitResident of
  LIBS:68040new/old on real 040 then self-unload.
- Reconstructed source/ (loader_lib.s + loader.c + helpers.s +
  endmodule.s); `make` builds a valid single-hunk .library.
- Status: FULL.
