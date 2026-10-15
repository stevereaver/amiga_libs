---
type: Library
title: dsp3210.library 6.0
description: >-
  '$VER: dsp3210.library 6.0 (20.8.2021)' — Thomas Winischhofer's
  AT&T DSP3210 loader/relocator library (d32 objects, 'DSPCOMPAT');
  single CODE hunk, non-AUTOINIT COLDSTART resident doing
  MakeLibrary+AddLibrary itself; 15 vectors. Direct successor of
  dsp3210 5.0 with a reworked guarded-free status contract and a
  new pointer-array free vector at -90.
files:
  - source/dsp3210_h0.s
  - source/fixup.py
  - source/Makefile
  - work/gen_source.py
  - work/oracle.py
---

# dsp3210.library 6.0 (20.8.2021, Thomas Winischhofer)

4396 bytes, one CODE hunk of 0x439 longs (4324B body at file
offset 0x20). sha256
`5d3a0b0666f1122549fa946e4281fb07f341764555b277d22139bd2817c1e022`,
md5 `0cd745d814c4facfec21a8928fb5b695`.

## Status

BYTE-IDENTICAL — `work/gen_source.py` emits verbatim asm
`source/dsp3210_h0.s` (data head 0x00-0x9c + word-offset functab
0x170-0x190 raw, rest as mnemonics/.short escapes); `fixup.py`
splices the original 5-entry RELOC32 tail. `cmp`-equal to
`binary/dsp3210_6.0.library`.

RUNTIME-IDENTICAL — `work/oracle.py` (machine68k) traces the
rt_Init MakeLibrary+AddLibrary bootstrap, libInit, all 15
vectors and DSPCalcLen/DSPRelocate on a synthetic d32 blob;
orig.log vs rebuild.log diff clean.

## Contents

- `structures/layout.md` — hunk map, resident, functab, strings
- `functions/vectors.md` — the 15-entry LVO table
- `findings/defects.md` — quirks and the 5.0→6.0 delta
- `log.md` — work journal

## Siblings

`dsp3210_1.1.library` (2 user fns, even error codes),
`dsp3210_3.0.library` (11 vectors, absolute-long functab),
`dsp3210_4.0.library` (14 vectors, word-offset functab, mixed
error codes), `dsp3210_5.0.library` (14 vectors, odd error-code
set). 6.0 keeps the 5.0 skeleton byte-for-byte except the deltas
listed in `findings/defects.md`.
