---
type: Log
title: Work Log
description: Analysis sessions for the Phase5 dummy 68040.library 44.1.
---

# Log

## 2026-10-10

- sha256 156f11f5c64ee8014f8b93f1128b7f0c6aa7c76f0e2f03b924f340fe46be5f47, 692 bytes.
- IRA disassembly (-M68040) into work/; decoded RomTag (ver 44),
  AUTOINIT InitTable (dataSize 0x38), absolute-long func table
  (4 entries, three separate null stubs).
- Identified: Phase5 "dummy" loader — opens dos.library, dispatches
  on AttnFlags 060/040/FPU40 bits; LoadSeg+InitResident preload of
  LIBS:68040new/old on real 040 then self-unloads; OpenLibrary
  ("060.library" — +7 pointer quirk) forwarding on FPU-less 040.
- Reconstructed source/ (dummy_lib.s + dummy.c + helpers.s +
  endmodule.s); `make` builds a valid single-hunk .library.
- Status: FULL.
