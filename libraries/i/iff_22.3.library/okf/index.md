---
type: Library
title: iff.library 22.3 (20.06.92, Christian A. Weber)
description: >-
  Weber iff.library 22.3 — earlier WB2-era IFF/ILBM toolkit; same
  25-vector API surface as 23.2 but a single older code base with a
  tail-only-funfunctab layout and a vestigial 4-byte DATA hunk.
timestamp: 2026-10-15T03:53:46Z
---
# iff.library 22.3 — OKF index

Binary: `binary/iff_22.3.library` — 3164 bytes, CODE hunk 0x2fb
longs (3052B) + a vestigial 4-byte zero DATA hunk; 10 same-hunk
RELOC32 entries; AUTOINIT RomTag at +0x34 (ver 22 rev 3).

Status: **byte-identical** verbatim-asm reconstruction
(`source/iff_h0.s`, md5 `edfc75560189f128a36a1d049bb4178d`),
RELOC32 tail spliced by `source/fixup.py`; machine68k oracle
identical over entry/init/all 25 vectors.

## Layout
- +0x00 module entry: sign-on banner (prints idstring via dos
  Output/Write — same quirk family as 23.2)
- +0x34 RomTag (RTF_AUTOINIT); name "iff.library"@+0x4e,
  idstr "IFF 22.3 (20.06.92) by Christian A. Weber..."@+0x5a,
  init@+0x92
- +0x92 InitTable: dsize 0x3c, functab +0xa2, datatab +0xd8,
  initfn +0xf8
- +0xa2 word-offset functab: LEADING 0xffff marker, 25 entries,
  0xffff terminator
- +0xd8 datatab (same private opcodes as 23.2: 0xa0/0x90/0x80)
- hunk1 DATA(0x3ea): 4 zero bytes — vestigial, nothing references it

See functions/vectors.md for the LVO map; findings/defects.md for
quirks; structures/layout.md for base layout.
