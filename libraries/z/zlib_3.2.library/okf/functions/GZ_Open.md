---
type: Function
title: GZ_Open (-30)
description: a0=filename d0=openmode d1=strategy d2=level. Builds a gz mode string (r|w + d|f|h + level digit) via getmode() then calls gzopen() from Amiga-adapted gzio.c.
isa: m68k
---

# GZ_Open (-30)

a0=filename d0=openmode d1=strategy d2=level. Builds a gz mode string (r|w + d|f|h + level digit) via getmode() then calls gzopen() from Amiga-adapted gzio.c.

Source: [source/func.c](../../../source/func.c). Wrapper naming and register args per [zlib_lib.fd](../../../source/zlib_lib.fd).
