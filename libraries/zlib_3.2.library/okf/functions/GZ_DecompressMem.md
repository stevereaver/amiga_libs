---
type: Function
title: GZ_DecompressMem (-120)
description: a0=src d0=srclen a1=dest d1=destlen. inflateInit + inflate(Z_FINISH) + inflateEnd on a stack z_stream; does NOT return produced length.
isa: m68k
---

# GZ_DecompressMem (-120)

a0=src d0=srclen a1=dest d1=destlen. inflateInit + inflate(Z_FINISH) + inflateEnd on a stack z_stream; does NOT return produced length.

Source: [source/func.c](../../../source/func.c). Wrapper naming and register args per [zlib_lib.fd](../../../source/zlib_lib.fd).
