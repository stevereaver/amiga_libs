---
type: Library
title: iff.library 22.1 (02.06.92, Christian A. Weber)
description: >-
  Weber iff.library 22.1 — WB2-era IFF/ILBM toolkit; same 25-vector
  API surface as 22.3, near-identical code base with a tail-only
  functab layout and a vestigial 4-byte DATA hunk.
timestamp: 2026-10-15T00:00:00Z
---
# iff.library 22.1 — OKF index

Binary: `binary/iff_22.1.library` — 3176 bytes, CODE hunk 0x2fe
longs (3064B) + a vestigial 4-byte zero DATA hunk; 10 same-hunk
RELOC32 entries; AUTOINIT RomTag at +0x34 (ver 22 rev 1, CHW
extended layout with an extra relocated long at +6).

Status: **byte-identical** verbatim-asm reconstruction
(`source/iff_h0.s`, md5 `3b33b332b5479ec3e0efed5c81cf5681`),
RELOC32 tail spliced by `source/fixup.py`; machine68k oracle
identical over entry/init/all 25 vectors + deferred expunge.

## Layout
- +0x00 module entry: sign-on banner (opens dos.library, Output(),
  Write()s 42 bytes of the idstring, CloseLibrary, returns 5)
- +0x34 RomTag (RTF_AUTOINIT); name "iff.library"@+0x4e,
  idstr "IFF 22.1 (02.06.92) by Christian A. Weber..."@+0x5a,
  init@+0x92
- +0x92 InitTable: dsize 0x3c, functab +0xa2, datatab +0xd8,
  initfn +0xf8
- +0xa2 word-offset functab: LEADING 0xffff marker, 25 entries,
  0xffff terminator
- +0xd8 datatab (private opcodes 0xa0/0x90/0x80)
- hunk1 DATA(0x3ea): 4 zero bytes — vestigial, nothing references it

See functions/vectors.md for the LVO map; findings/defects.md for
quirks and the 22.1-vs-22.3 delta; structures/layout.md for base
layout.
