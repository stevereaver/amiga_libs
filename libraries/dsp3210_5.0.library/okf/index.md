---
type: Library
title: dsp3210.library 5.0
description: >-
  '$VER: dsp3210.library 5.0 (4.8.2021)' — Thomas Winischhofer's
  AT&T DSP3210 loader/relocator library (d32 objects, 'DSPCOMPAT');
  single CODE hunk, non-AUTOINIT COLDSTART resident doing
  MakeLibrary+AddLibrary itself; 14 vectors. Direct successor of
  dsp3210 4.0 with a renumbered (odd) error-code set and one
  reworked internal call site.
files:
  - source/dsp3210_h0.s
  - source/fixup.py
  - source/Makefile
  - work/gen_source.py
  - work/oracle.py
---

# dsp3210.library 5.0 (4.8.2021, Thomas Winischhofer)

4356 bytes, one CODE hunk of 0x42f longs (4284B body at file
offset 0x20). sha256
`54be806f3a1fb9e4b5570062ce0affa1f54ba3c0745272d06fa135bd25cacaca`,
md5 `77f251fe452bd0aab81816660bfc0c96`.

## Status

BYTE-IDENTICAL — `work/gen_source.py` emits verbatim asm
`source/dsp3210_h0.s` (data head 0x00-0x9c + word-offset functab
0x170-0x18e raw, rest as mnemonics/.short escapes); `fixup.py`
splices the original 5-entry RELOC32 tail. `cmp`-equal to
`binary/dsp3210_5.0.library`.

RUNTIME-IDENTICAL — `work/oracle.py` (machine68k) traces the
rt_Init MakeLibrary+AddLibrary bootstrap, libInit, all 14
vectors and DSPCalcLen/DSPRelocate on a synthetic d32 blob;
orig.log vs rebuild.log diff clean.

## Contents

- `structures/layout.md` — hunk map, resident, functab, strings
- `functions/vectors.md` — the 14-entry LVO table
- `findings/defects.md` — quirks and the 4.0→5.0 delta
- `log.md` — work journal

## Siblings

`dsp3210_1.1.library` (2 user fns, even error codes),
`dsp3210_3.0.library` (11 vectors, absolute-long functab),
`dsp3210_4.0.library` (14 vectors, word-offset functab, mixed
error codes). 5.0 keeps the 4.0 skeleton byte-for-byte except the
deltas listed in `findings/defects.md`.
