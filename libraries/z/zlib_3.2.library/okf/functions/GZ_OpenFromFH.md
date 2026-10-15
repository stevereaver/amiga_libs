---
type: Function
title: GZ_OpenFromFH (-36)
description: Same as GZ_Open but a0=BPTR file handle; calls gzdopen(). gzdopen with NULL fh returns NULL.
isa: m68k
---

# GZ_OpenFromFH (-36)

Same as GZ_Open but a0=BPTR file handle; calls gzdopen(). gzdopen with NULL fh returns NULL.

Source: [source/func.c](../../../source/func.c). Wrapper naming and register args per [zlib_lib.fd](../../../source/zlib_lib.fd).
