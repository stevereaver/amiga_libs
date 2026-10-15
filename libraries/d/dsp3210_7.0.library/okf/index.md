---
type: Library
title: dsp3210.library 7.0
description: >-
  '$VER: dsp3210.library 7.0 (29.8.2021)' — Thomas Winischhofer's
  AT&T DSP3210 loader/relocator library (d32 objects, 'DSPCOMPAT');
  single CODE hunk, non-AUTOINIT COLDSTART resident doing
  MakeLibrary+AddLibrary itself; 15 vectors. Direct successor of
  dsp3210 6.0 adding a second magic cookie (0x00fc2011) marking
  "container" objects with an embedded MinList, and making -60/-66/-90
  and the loader's allocation tail container-aware.
files:
  - source/dsp3210_h0.s
  - source/fixup.py
  - source/Makefile
  - work/gen_source.py
  - work/oracle.py
---

# dsp3210.library 7.0 (29.8.2021, Thomas Winischhofer)

4648 bytes, one CODE hunk of 0x478 longs (4576B body at file
offset 0x20). sha256
`41597218a0ad55bb61c5a290d6db497dfc68ea5af25f49099c561ae7de9f4402`,
md5 `771f9beb2ae9360e3a615ba52854be6c`.

## Status

BYTE-IDENTICAL — `work/gen_source.py` emits verbatim asm
`source/dsp3210_h0.s` (data head 0x00-0x9c + word-offset functab
0x170-0x190 raw, rest as mnemonics/.short escapes); `fixup.py`
splices the original 5-entry RELOC32 tail. `cmp`-equal to
`binary/dsp3210_7.0.library`.

RUNTIME-IDENTICAL — `work/oracle.py` (machine68k) traces the
rt_Init MakeLibrary+AddLibrary bootstrap, libInit, all 15
vectors and DSPCalcLen/DSPRelocate on a synthetic d32 blob;
orig.log vs rebuild.log diff clean. Delta vs the 6.0 oracle log
is exactly one line: -54 now returns the lib base instead of the
adjusted block pointer (new status protocol).

## Contents

- `structures/layout.md` — hunk map, resident, functab, strings
- `functions/vectors.md` — the 15-entry LVO table
- `findings/defects.md` — quirks and the 6.0→7.0 delta
- `log.md` — work journal

## Siblings

`dsp3210_1.1.library` (2 user fns, even error codes),
`dsp3210_3.0.library` (11 vectors, absolute-long functab),
`dsp3210_4.0.library` (14 vectors, word-offset functab, mixed
error codes), `dsp3210_5.0.library` (14 vectors, odd error-code
set), `dsp3210_6.0.library` (15 vectors, status-protocol -66,
new -90). 7.0 keeps the 6.0 skeleton byte-for-byte except the
deltas listed in `findings/defects.md`. A `dsp3210_7.1.library`
sibling exists with the same size and nearly identical layout
(version string `7.1 (12.12.2021)` plus small code tweaks).
