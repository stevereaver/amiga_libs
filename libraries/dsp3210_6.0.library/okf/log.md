---
type: Log
title: dsp3210 6.0 work log
---

# Work log

- Single-hunk COLDSTART dsp3210 6.0 (4396B; hunk0 CODE 0x439
  longs = 4324B, 40B larger than 5.0). Reused the verified
  dsp3210_5.0.library pipeline: `work/gen_source.py` with only
  BIN path, body size (0x10e4) and the functab DATA span adapted
  (grew from 0x170-0x18e to 0x170-0x190 for the 15th vector);
  `source/Makefile` + `source/fixup.py` adapted to the 6.0 path.
- `make` -> gas assembles the verbatim .s, GNU ld emits the
  single hunk, fixup.py verifies the hunk body matches and
  splices the original RELOC32 tail (5 entries, descending:
  0x1a 0x16 0x12 0xa 0x6 — the resident pointer fields).
  Result: `cmp` BYTE-IDENTICAL (md5 0cd745d814c4facfec21a8928fb5b695).
- `work/oracle.py` (machine68k, comment + default nv=15
  adapted): module entry -> MakeLibrary(15 vectors, dsize 0x2c)
  + AddLibrary; libInit; all 15 LVOs; synthetic d32 blob calls
  (DSPCalcLen -30 -> 4, DSPRelocate -36 -> -5, both -1 on bad
  magic). orig.log == rebuild.log, diff clean.
- Diffed against the 5.0 sibling: same skeleton, same odd error
  codes, entry stub now returns -1, the -66 guarded-free became
  a -1/0 status function with a relaxed (even-only) alignment
  check, new -90 vector frees a NULL-terminated pointer array
  via -66, and the 2 pad bytes after the DSP register-name table
  were dropped (+40B net).
