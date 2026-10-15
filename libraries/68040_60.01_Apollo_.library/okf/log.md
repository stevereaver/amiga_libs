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

## 2026-10-15

- Rewrote source/ as pure 68k asm (68040.s, gas -m68000): `make` now
  produces a **byte-identical** rebuild —
  md5 a87e68a0e398d03466cc5443f524fbe7 for both original and rebuild.
  No fixup.py needed: the single-source reloc order comes out
  ascending (06 0a 12 16 1a 70 74 78 7c 80 84 88 96 a8) exactly as
  shipped. Old C build retained as `make cmodel` (68040-c.library).
- Capstone re-verification corrected a semantic error in the old
  notes: `cmpi.w #$80ff,AttnFlags` runs *after* `move.l d7,d0`, so
  AttnFlags==$80ff returns the base (success, "already installed"
  marker) — not NULL. loader.c + okf updated.
- Added work/oracle.py (machine68k): AUTOINIT MakeLibrary emulation,
  InitStruct decode, init scenario matrix over AttnFlags
  (0x0000/0x0008/0x0048/0x80ff + OpenLibrary failure) and all four
  vectors. Original and rebuild produce identical logs.
