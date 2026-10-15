---
type: Log
title: dsp3210 5.0 work log
---

# Work log

- Single-hunk COLDSTART dsp3210 5.0 (4356B; hunk0 CODE 0x42f
  longs = 4284B, 16B larger than 4.0). Reused the verified
  dsp3210_4.0.library pipeline: `work/gen_source.py` with only
  BIN path and body size adapted (same DATA spans 0x0-0x9c and
  0x170-0x18e apply verbatim); `source/Makefile` +
  `source/fixup.py` adapted to the 5.0 path.
- `make` -> gas assembles the verbatim .s, GNU ld emits the
  single hunk, fixup.py verifies the hunk body matches and
  splices the original RELOC32 tail (5 entries, descending:
  0x1a 0x16 0x12 0xa 0x6 — the resident pointer fields).
  Result: `cmp` BYTE-IDENTICAL (md5 77f251fe452bd0aab81816660bfc0c96).
- `work/oracle.py` (machine68k, adapted comment only): module
  entry -> MakeLibrary(14 vectors, dsize 0x2c) + AddLibrary;
  libInit; all 14 LVOs; synthetic d32 blob calls
  (DSPCalcLen -30 -> 4, DSPRelocate -36 -> -5, both -1 on bad
  magic). orig.log == rebuild.log, diff clean.
- Diffed against the 4.0 sibling: same skeleton, error codes
  renumbered to the odd set, one internal call site reworked to
  an out-parameter protocol (+14B) plus a 2-byte alignment pad
  after the DSP register-name table (+16B total).
