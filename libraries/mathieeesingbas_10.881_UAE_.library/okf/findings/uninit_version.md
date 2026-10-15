---
type: Finding
title: lib_Version / lib_IdString left zero
description: The InitStruct stream never writes lib_Version or lib_IdString.
---

# lib_Version / lib_IdString left zero

The datatab (`a0 0e 06 00 90 16 03 71 00 00`) only writes
lib_Flags = 0x06 and lib_Revision = 881.  It never writes lib_Version
(offset 0x14) or lib_IdString (offset 0x18), so a MakeLibrary-built base
keeps 0 in both fields -- the "MSB 10.881" string and version 45 live
only in the RomTag (rt_IdString / rt_Version).

Confirmed by `work/oracle.py`: after InitStruct, `ver=0 rev=881`.
Unlike most C-linked libraries of the era, no `INITWORD 0x14` /
`INITLONG 0x18` records exist here.  A version-checked
OpenLibrary("mathieeesingbas.library", N>0) would fail for this image.
