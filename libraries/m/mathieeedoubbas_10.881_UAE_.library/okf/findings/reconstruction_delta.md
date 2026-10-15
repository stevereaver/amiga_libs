---
type: Finding
title: Reconstruction deltas
description: Rebuilt vs shipped library -- now byte-identical.
---

# Reconstruction deltas

**None.**  `source/mathieeedoubbas_h0.s` is a verbatim transcription of
the 0x230-byte CODE hunk; `make` assembles+links it with
m68k-amigaos-gcc `-m68000 -Wa,-m68881 -nostdlib -Wl,-s` and `fixup.py`
rewrites GNU ld's HUNK_RELOC32 tail into the original compact 16-bit
0x3f7 (RELOC32SHORT/DREL16) chunk.  Result: md5
`d045e9dab808f9331ad97bfc85e795dd` = the shipped binary, all 624 bytes.

All 68881 F-line words assemble byte-identically under gas `-Wa,-m68881`
(`fmovel d0,fpcr`, `fmoved (a7)+/(a7),fp0/fp1`, `fmoved fp0,-(a7)/(a7)`,
`fmovel d0,fp0`, `fmovel fp0,d0`, `faddd/fsubd/fmuld/fdivd (a7),fp0`,
`fintrzx fp1,fp0`, `fcmpx fp1,fp0`, `fbule/fbuge .w`, `fsubs/fadds
#0e1,fp0`).

## Earlier C+asm model

Kept as `make cmodel` (semantic documentation, larger binary).  Its
LibInit no-FPU path was corrected: it used to FreeMem the *OpenLibrary*
result; the shipped code frees the new library base instead (see
`findings/nofpu_init.md`).
