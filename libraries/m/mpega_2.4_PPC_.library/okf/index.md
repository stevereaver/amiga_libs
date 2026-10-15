---
type: Library
title: mpega.library 2.4 (PPC) (13.9.99, Stephane Tavenard)
description: >-
  Tavenard mpega.library 2.4 PPC variant — 68k glue library that
  delegates MPEG audio decoding to a PowerPC companion binary
  (mpegappc_library.elf) loaded through ppc.library.
files:
  - source/mpega_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# mpega.library 2.4 (PPC)

GCC-style build.  Two hunks: hunk0 CODE (2404 bytes, pure code),
hunk1 DATA (560 bytes).  The Resident is embedded inside the DATA
hunk at +0x100 — exec's InitResident scan finds it there.
InitTable lives at hunk1+0; all code is `a4`-relative against the
DATA hunk (every function preamble is `lea h1,a4`).

## Build

`source/mpega_h0.s` is a verbatim transcription (hunk0 = code,
hunk1 emitted as a `.data` section of raw bytes).  `fixup.py`
splits the generated DATA hunk back into the original hunk
structure and splices the original RELOC32 tails (three groups:
hunk0->hunk1 code operands, hunk1->hunk0 functab, hunk1->hunk1
resident/datatab pointers).  `make` produces a byte-identical
binary (md5 `9273db325c5bccff7faef68e9b035e8c`).

## Layout

- hunk1+0x00: InitTable — datasize 0x2a, functab->h1+0x10,
  datatab->h1+0x11c (byte-command InitData with 24-bit offsets
  and relocated long fields), initfn->h0+0xe
- hunk1+0x10: functab — 11 absolute longs into hunk0 + 0xffffffff
- hunk1+0x54: 'mpega.library'; +0x64: idstring
  'mpega 2.4 (13.9.99) [PPC] MPEG Audio decoding library ...'
- hunk1+0x100: Resident (AUTOINIT, version 2, type NT_LIBRARY)
- hunk1+0x144+: 'dos.library', 'ppc.library',
  'mpegappc_library.elf', 'LIBS:mpegappc_library.elf' fallback,
  port/message names
- hunk0+0x00: hunk-zero stub — `lea h1,a4; moveq #-1,d0; rts`
  (returns -1 if entered as a segment entry point)

## Vectors (11)

See `okf/functions/vectors.md`.

## Runtime

`work/oracle.py` loads both hunks, finds the embedded Resident in
the DATA hunk, runs the InitData stream (byte-command format with
24-bit offsets), installs all 11 vectors, and exercises initfn
(dos.library + ppc.library v44 open, PPC companion load with
LIBS: fallback, PPC calls, closelibs), Open x2, all vectors,
Close x2, and Expunge.  Original and rebuilt binaries produce
identical logs.
