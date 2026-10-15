---
type: Log
title: Work journal
---

# Log

## 2026-10-10

- Disassembled (ira → work/dsp3210_1.1.asm); found a NON-AUTOINIT
  resident module (rt_Flags=0) whose rt_Init calls MakeLibrary(-84)
  and AddLibrary(-396) itself, with a manual InitBase field init.
- Resolved all 6 LVO slots; identified the two user functions as the
  d32 blob loader: fetched the official `dsp3210_lib.fd` +
  `libraries/dsp3210.h` from Aminet `driver/other/dsp3210` (Thomas
  Winischhofer, realA10001986/AmigaDSP3210) — names DSPCalcLen (-30)
  and DSPRelocate (-36) confirmed.
- Fully decoded the blob format (0x0166 magic, 40-byte section
  records, 18-byte symbols, 16-byte reloc records, reloc types
  0x1c/0x2c/0x2e/0x2f) and the internal/external symbol resolution.
- Reconstructed C source (dsp3210_lib.s + dsp3210.c + dspbase.h);
  verified generated code: identical exec LVO targets (-84/-396/
  -198/-210/-252), same magic/flag/type compares, same byte-copy loop,
  same pre-decrement OpenCnt test.
- Documented API drift vs the v7 FD (pair-array extsyms, extra d0
  bound, even error codes) and findings.

## 2026-10-15 (verbatim asm rebuild)
- `dsp3210_h0.s` byte-verbatim; header/strings 0x00-0x55 raw, code
  0x56+ as mnemonics; .short for immforms/zero-disp/oob refs.
- fixup.py splices the original RELOC32 tail (descending offsets
  then RomTag fields — GNU ld order differs).
- `make` -> BYTE-IDENTICAL (md5 80b56d6f33b764b86ba8a80383d4cb27).
- `work/oracle.py`: non-AUTOINIT path — MakeLibrary trap builds the
  base, libInit called as exec would; DSPCalcLen(-30) -> 4 and
  DSPRelocate(-36) -> -3 (AllocMem 4) on a valid 1-section blob;
  both -1 on bad magic.  Identical orig vs rebuild.
