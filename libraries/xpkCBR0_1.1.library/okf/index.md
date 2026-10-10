---
type: Library
title: xpkCBR0.library V1.1 "Cmp Byte Run 0 Packer"
description: >-
  XPK compression sublibrary implementing the simplest
  possible byte-oriented RLE (literal runs <=128, repeat
  runs 2..129).  AUTOINIT word-offset functab; 0xaa-byte
  base embeds runtime-initialised XpkInfo/XpkMode
  descriptors; entry stub returns -1.
timestamp: 2026-10-11T00:10:00Z
---

# xpkCBR0.library V1.1

XPK sublibrary ("Cmp Byte Run 0") — trivial RLE codec:
header <0x80 emits a literal run of h+1 bytes (1..128),
header >=0x80 emits a repeat run of 257-h bytes (2..129).
No stream terminator; the decoder stops at input
exhaustion.

Same sublibrary family as xpkFRLE/xpkRLEN, but the
XpkInfo/XpkMode descriptors are written into the library
base by LibInit at runtime (dataSize 0xaa) instead of
being static data, and the three unused sublib slots
point at a bare `rts` rather than the null stub.

## Binary facts

- 948 bytes, single CODE hunk (0x358 bytes)
- RomTag: RTF_AUTOINIT, RT_VERSION 1, NT_LIBRARY
- RT_ENDSKIP at hunk end (0x358)
- name `xpkCBR0.library`; idstring `xpkCBR0 v1.1\r\n`
  (no $VER: cookie)
- module entry `moveq #-1,d0/rts` (returns -1)
- InitTable: dataSize 0xaa, word-offset functab
  (-1 marker, 10 entries, -1), InitStruct datatab,
  initFunc
- InitStruct: NT_LIBRARY, flags 0x06, version 1, rev 1
- textbook DELEXP in lib_Flags bit3
- XpkInfo at base+0x28 (88 B), XpkMode at base+0x80
  (42 B), both written by LibInit

## Status

FULL — reconstructed (`source/`): C framework + codec
(xpkCBR0.c), resident tables/strings (xpkCBR0_lib.s),
two-pass word-offset functab (genfunctab.py).  Codec
round-trip verified on a host model (20k random chunks,
all pass); descriptor field writes verified field-for-field
against the shipped LibInit.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [algorithms/](algorithms/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
