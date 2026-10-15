---
type: Library
title: iff.library 23.2 (24.5.93, Christian A. Weber)
description: >-
  Weber iff.library: FORM/ILBM parser with BMHD/CMAP/BODY/CAMG/DLTA
  chunk support and xpkmaster-backed compressed chunk reads.
  Byte-identical verbatim-asm reconstruction.
timestamp: 2026-10-15T03:43:30Z
---

# iff.library 23.2 — OKF index

Binary: `binary/iff_23.2.library` — 3160 bytes, single CODE hunk
(0x2ff longs), AUTOINIT RomTag at +0x2e, 10 same-hunk RELOC32
entries at +0x30/0x34/0x3c/0x40/0x44/0x98/0x9c/0xa0/0xe0/0xf2.

Identity: "IFF 23.2 (24.5.93) (-: by Christian A. Weber :-)" —
the iff.library distributed with IFFP/iff tools.

Status: **byte-identical** verbatim-asm reconstruction
(`source/iff_h0.s`, md5 `3f3562b6bfc6288498f8f88b3ff504f4`),
RELOC32 tail spliced by `source/fixup.py`. Runtime-identical over
module-entry/init/all-25-vectors oracle (`work/oracle.py`).

## Layout
- +0x00 module entry: sign-on banner (see findings)
- +0x2e RomTag (RTF_AUTOINIT, ver 23 rev 2, name "iff.library")
- +0x94 InitTable: dsize 0x3c, functab +0xa4, datatab +0xda,
  initfn +0xfa
- +0xa4 word-offset functab: 0xffff marker, 25 entries, 0xffff term
- +0xda datatab (custom opcodes: 0xa0=2-byte init, 0x90=word init,
  0x80=relocated-long init, 0=term)
- vectors code +0x128..+0xbb0 (see functions/vectors.md)
