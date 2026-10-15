---
type: Library
title: asyncio.library 39.1 (7.6.97)
description: >-
  asyncio.library 39.1 — asynchronous file-I/O library; 17-vector
  AUTOINIT library with an in-hunk Resident and a trailing BSS hunk.
files:
  - source/asyncio_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# asyncio.library 39.1

Two hunks: hunk0 CODE (3100 bytes), hunk1 BSS (20 bytes — present
in the hunk table but with no file body).  Code-hunk layout:

- +0x00: `moveq #0,d0; rts` module-entry stub
- +0x04: functab — 17 absolute longs + 0xffffffff (LVOs -6..-102)
- +0x4c: InitTable — datasize 0x22, functab->+4, datatab=0,
  initfn->+0x106
- +0x5c: idstring 'asyncio.library 39.1 (7.6.97)'
- +0x7c: 'asyncio.library', +0xa6: 'dos.library',
  +0xb2: 'utility.library'
- +0x8c: Resident (AUTOINIT), mid-hunk
- +0xc6..: code; initfn opens dos.library + utility.library v37

## Build

`source/asyncio_h0.s` is a verbatim transcription; the 20-byte BSS
is emitted as a `.data` block of zeros and `fixup.py` rewrites the
shipped layout: original 2-hunk header, CODE hunk + spliced
RELOC32 tail, then the body-less BSS hunk + END.  `make` produces
a byte-identical binary (md5 of the rebuilt file).

## Runtime

`work/oracle.py` loads CODE + BSS, applies both reloc groups
(including the 10 code operands that point into the BSS hunk),
runs initfn, installs all 17 vectors, and exercises open x2,
every LVO, close x2 (deferred-expunge path included) and real
expunge.  Original and rebuilt logs identical.
