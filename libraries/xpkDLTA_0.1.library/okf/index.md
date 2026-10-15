---
type: Library
title: xpkDLTA.library V0.1 "DELTA-Encryption Routines"
description: >-
  XPK compression sublibrary by Stephan Fuhrmann (1992)
  doing size-preserving byte-delta coding ("encryption" is
  marketing): pack emits in[0] then in[i]-in[i-1], unpack
  accumulates.  Absolute-longword functab; 0xfc-byte base
  embeds InitStruct-filled XpkInfo/XpkMode; entry stub
  returns 0; word/long delta kernels shipped as dead code.
timestamp: 2026-10-11T00:45:00Z
---

# xpkDLTA.library V0.1

XPK sublibrary ("ByteMode" delta packer).  Transforms are
size-preserving so compressed chunks hold byte deltas —
useful only as a preconditioner inside larger streams.

Distinct framework style vs xpkFRLE/xpkCBR0: absolute
-longword functab, a 0xfc-byte base whose descriptor
fields are filled by the *InitStruct stream* (LibInit only
patches xi_ModeDesc and the seglist), and a v0.1
($VER:-cookied) idstring.

## Binary facts

- 960 bytes, single CODE hunk (0x320 bytes)
- RomTag: RTF_AUTOINIT, RT_VERSION 0 (!), NT_LIBRARY
- RT_ENDSKIP at hunk end (0x320)
- name `xpkDLTA.library`; idstring
  `xpkDLTA.library v0.1` — which sits *inside* the
  `$VER: xpkDLTA.library v0.1` string (overlapping)
- module entry `moveq #0,d0/rts` (returns 0)
- InitTable: dataSize 0xfc, abs-longword functab
  (10 entries + -1), datatab, initFunc
- InitStruct also writes XpkInfo fields at base+0x26 and
  XpkMode fields at base+0x82/0x9e ("ByteMode")
- textbook DELEXP in lib_Flags bit3
- expunge calls an empty cleanup-hook rts first

## Status

Byte-identical.  `make` assembles `source/xpkDLTA_h0.s`
(verbatim asm; the functab's absolute longs and all RomTag
/datatab pointers relocate normally -- 27 ascending
RELOC32 entries, no fixup needed).  `make cmodel` builds
the earlier C reconstruction.
Runtime-verified: `work/oracle.py` (machine68k) logs
identical for original vs rebuild across init, Open/Close,
deferred+real expunge (incl. the dead bsr-to-rts hook),
all stubs, XpkInfo layout, pack/unpack round-trip with
xsp+0x34/0x38 chunk chaining, and -10/-11 error paths.


## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [algorithms/](algorithms/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
