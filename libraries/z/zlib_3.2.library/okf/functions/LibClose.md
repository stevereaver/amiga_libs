---
type: Function
title: LibClose (-12)
description: Decrements lib_OpenCnt; if it reaches 0 and LIBF_DELEXP is set, calls LibExpunge.
isa: m68k
---

# LibClose (-12)

Decrements lib_OpenCnt; if it reaches 0 and LIBF_DELEXP is set, calls LibExpunge.

Source: [source/func.c](../../../source/func.c). Wrapper naming and register args per [zlib_lib.fd](../../../source/zlib_lib.fd).
