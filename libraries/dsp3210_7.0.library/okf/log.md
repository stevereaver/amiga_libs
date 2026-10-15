---
type: Log
title: dsp3210 7.0 work log
---

# Work log

- Single-hunk COLDSTART dsp3210 7.0 (4648B; hunk0 CODE 0x478
  longs = 4576B, 252B larger than 6.0). Reused the verified
  dsp3210_6.0.library pipeline verbatim: `work/gen_source.py`
  with only BIN path and body size (0x11e0) changed — the DATA
  spans (0x0-0x9c resident+strings, 0x170-0x190 functab) are
  identical since the header layout did not move;
  `source/Makefile` + `source/fixup.py` adapted to the 7.0 path.
- `make` -> gas assembles the verbatim .s, GNU ld emits the
  single hunk, fixup.py verifies the hunk body matches and
  splices the original RELOC32 tail (5 entries, descending:
  0x1a 0x16 0x12 0xa 0x6 — the resident pointer fields).
  Result: `cmp` BYTE-IDENTICAL (md5 771f9beb2ae9360e3a615ba52854be6c).
- `work/oracle.py` (machine68k, copied from 6.0 unchanged —
  same 15 vectors, same dsize 0x2c): module entry ->
  MakeLibrary(15 vectors) + AddLibrary; libInit; all 15 LVOs;
  synthetic d32 blob calls (DSPCalcLen -30 -> 4, DSPRelocate
  -36 -> -5, both -1 on bad magic). orig.log == rebuild.log,
  diff clean.
- Diffed against the 6.0 sibling: same skeleton, same error
  codes, functab unchanged at +0x170 (15 entries). The release
  adds a container object model keyed on a new cookie
  `0x00fc2011` (table@+4, embedded MinList@+8, nodes with
  key@+8 and payload@+12). -60/-66/-90 dispatch on it; the old
  -66 block-free was factored into a shared subroutine at
  h0+0xbe0; -54 gained the -1/0-style status protocol (returns
  libbase on bad args — oracle-visible delta, 0x100000 vs
  0x4ff00); the loader's AllocMem tail AddTails nodes into
  container lists; DSPRelocate now calls the -60 body instead
  of an inlined array scan. -72 scanner and -84 status are
  byte-identical modulo the +0xbc shift; register-name table
  moved to +0xfea; trailing pad gone — body ends on `rts`.
- Note: sibling `dsp3210_7.1.library` (4648B, same shape,
  idstr `7.1 (12.12.2021)`) exists but was not part of this
  task; it differs from 7.0 in the idstr and a handful of code
  bytes (e.g. resident version, `dmac` table area operands).
