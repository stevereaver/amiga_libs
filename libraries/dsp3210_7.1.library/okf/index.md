---
type: Library
title: dsp3210.library 7.1
description: >-
  '$VER: dsp3210.library 7.1 (12.12.2021)' — Thomas Winischhofer's
  AT&T DSP3210 loader/relocator library (d32 objects, 'DSPCOMPAT');
  single CODE hunk, non-AUTOINIT COLDSTART resident doing
  MakeLibrary+AddLibrary itself; 15 vectors. Bugfix release of
  7.0: same container model (0x00fc2011), plus lib_Revision=1,
  d4=0 instead of 0x100 in the dos -906 DSPCOMPAT probe, and an
  explicit terminator on the DSP register-name record list.
files:
  - source/dsp3210_h0.s
  - source/fixup.py
  - source/Makefile
  - work/gen_source.py
  - work/oracle.py
---

# dsp3210.library 7.1 (12.12.2021, Thomas Winischhofer)

4648 bytes, one CODE hunk of 0x478 longs (4576B body at file
offset 0x20). sha256
`c4718a6f9f05029cec2505f985e6a14b2a6259703a849aac86e83b396d5baa39`,
md5 `cf2425cd321c067edf6f7eb2e325b8b3`.

## Status

BYTE-IDENTICAL — `work/gen_source.py` emits verbatim asm
`source/dsp3210_h0.s` (data head 0x00-0x9c + word-offset functab
0x172-0x192 raw, rest as mnemonics/.short escapes); `fixup.py`
splices the original 5-entry RELOC32 tail. `cmp`-equal to
`binary/dsp3210_7.1.library`.

RUNTIME-IDENTICAL — `work/oracle.py` (machine68k) traces the
rt_Init MakeLibrary+AddLibrary bootstrap, libInit (incl. the new
lib_Revision=1 write), all 15 vectors, DSPCalcLen/DSPRelocate on
a synthetic d32 blob, and the container ops (-60/-66/-90/-54)
on synthetic `0x00fc2011` objects. exec is stubbed, plus a fake
dos.library whose -906 probe call reveals the 7.1 d4=0 argument.
orig.log vs rebuild.log diff clean.

## Contents

- `structures/layout.md` — hunk map, resident, functab, strings
- `functions/vectors.md` — the 15-entry LVO table
- `findings/defects.md` — quirks and the 7.0→7.1 delta
- `log.md` — work journal

## Siblings

`dsp3210_1.1.library` (2 user fns, even error codes),
`dsp3210_3.0.library` (11 vectors, absolute-long functab),
`dsp3210_4.0.library` (14 vectors, word-offset functab, mixed
error codes), `dsp3210_5.0.library` (14 vectors, odd error-code
set), `dsp3210_6.0.library` (15 vectors, status-protocol -66,
new -90), `dsp3210_7.0.library` (adds the 0x00fc2011 container
model). 7.1 keeps the 7.0 skeleton and every vector byte-for-byte
modulo displacement shifts; deltas listed in
`findings/defects.md`.
