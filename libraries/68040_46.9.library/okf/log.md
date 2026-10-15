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

## 2026-11-20

- Upgraded to byte-identical pure-asm rebuild `source/68040.s`
  (`make` default target; `make cmodel` keeps the C model).
  md5 `32ad08d5d71301b0bf9b494bc39cdffe`, 568 bytes.
- One canonicalization fix: the fault handler's `addq.l #4,2(a7)`
  (`58af 0002`, skipping the whole 4-byte `movec`) — an earlier
  draft emitted `addq.l #2`.
- machine68k oracle (work/oracle.py): Supervisor stub really invokes
  the probe with a supervisor SR; on CPU models without PCR the
  `movec pcr` faults into the patched vector-4 handler and init takes
  the LoadSeg/RomTag-scan/InitResident path (returns NULL regardless
  — preload-then-die). A forced probe=1 scenario exercises the
  OpenLibrary("68060.library") path and confirms LibOpen returns the
  proxied base. Traces identical original vs rebuild on both
  M68030 and M68040: RUNTIME-IDENTICAL.
- Corrected stale docs: name pointers target the string starts
  ("68060.library"/"Libs:68040mmu.library"), not str+2 as previously
  recorded.
- Status: DONE.
