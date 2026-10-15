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

## 2026-10-15

- Rewrote as verbatim asm `source/68040_v.s` — byte-identical (md5
  8333b7778869e23f481d32c03cf48f30).  `fixup.py` rewrites the reloc
  tail to the original 0x3f7 DREL16 (14 offsets, stored out of order:
  a,12,16,1a,d8-ec,f0,110,fe,6).
- machine68k oracle RUNTIME-IDENTICAL, 7 scenarios.  The supervisor
  probe executes for real: `movec vbr,a0` + `movec pcr,a1` faults on
  the M68040 model → vector-4 fault handler skips 4 bytes → d0=0 →
  LoadSeg path; forced d0=1 covers the 060 OpenLibrary path.  (rte
  format word quirk: fake exception frames need the 8-byte form.)
- Corrected Quirks.md: the 060-path name is "68060.library" (+5 into
  "LIBS:68060.library"); the claimed +7 "060.library" delta vs 44.1
  does not exist — both dummies use +5.
