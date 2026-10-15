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

## 2026-10-15

- Rewrote as verbatim assembly `source/dummy_v.s` +
  `source/fixup.py` (rewrites GNU ld RELOC32 tail to the original
  0x3f7 RELOC32SHORT with the out-of-order offset list
  a,12,16,1a,d4-dc,e0-ec,10c,fa,6). `make` → byte-identical
  (md5 ad4ecfe10758fd8d54aa59fdc7e0edb5).
- machine68k oracle: 7 scenarios, RUNTIME-IDENTICAL —
  060 pass-through, non-040 fail, FPU40 new/old LoadSeg+
  RomTag-walk+InitResident (init returns 0 either way — the dummy
  self-frees), no-RomTag → UnLoadSeg, FPU-less 040 →
  OpenLibrary("68060.library") → lib+0x28, open proxying to
  lib+0x28 or self, all three stub vectors.
- Corrected prior docs: the OpenLibrary name is "68060.library"
  (+5 past "LIBS:"), not "060.library" (+7). Datatab commands are
  word-aligned (pad bytes before commands at odd offsets).
