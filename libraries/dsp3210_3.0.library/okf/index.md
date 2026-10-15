---
type: Library
title: dsp3210.library 3.0
description: >-
  '$VER: dsp3210.library 3.0 (6.6.2021)' — AT&T DSP3210
  loader/relocator library (d32 objects); single CODE hunk,
  non-AUTOINIT resident doing MakeLibrary+AddLibrary itself;
  11 vectors.
files:
  - source/dsp3210_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# dsp3210.library 3.0

Single 3512B CODE hunk, 28 RELOC32 entries (descending).

- Resident@+4: flags=0 (NON-AUTOINIT), v3; name->0x1e
  'dsp3210.library', id->0x34 '$VER: dsp3210.library 3.0
  (6.6.2021)', rt_Init->0x64 = bootstrap routine
- bootstrap: calls exec MakeLibrary(-84) with functab@0x138
  (11 absolute longs + ffffffff), AddLibrary(-396)
- second internal pointer table@0xbec..0xc18 (12 ->h0 longs
  to 0xc20..0xc70)
- strings: dos.library, 'timer', '*icnt', '.ocnt', '3dmac'
  (DSP3210 timer/DMA register names)
- sibling of dsp3210_1.1.library (same MakeLibrary skeleton)

## Build

`dsp3210_h0.s` verbatim .text; `fixup.py` splices the
descending RELOC32 tail.  Byte-identical (md5 0d51946dbf2534a6e17e98e064ad103f).

## Runtime

`work/oracle.py`: module entry -> MakeLibrary(11 vectors,
dsize 46+34) + AddLibrary; libInit; all 11 vectors; d32
payload calls (valid blob: DSPCalcLen->4 / DSPRelocate path;
bad-magic: 0xffffffff).  Identical original vs rebuild.
