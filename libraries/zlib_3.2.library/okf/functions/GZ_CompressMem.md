---
type: Function
title: GZ_CompressMem (-114)
description: a0=src d0=srclen a1=dest d1=destlen d2=strategy d3=level a2=poutlen. deflateInit2_(Z_DEFLATED, MAX_WBITS, memLevel 8, strategy) + deflate(Z_FINISH) + deflateEnd on a stack z_stream; writes total_out to poutlen.
isa: m68k
---

# GZ_CompressMem (-114)

a0=src d0=srclen a1=dest d1=destlen d2=strategy d3=level a2=poutlen. deflateInit2_(Z_DEFLATED, MAX_WBITS, memLevel 8, strategy) + deflate(Z_FINISH) + deflateEnd on a stack z_stream; writes total_out to poutlen.

Source: [source/func.c](../../../source/func.c). Wrapper naming and register args per [zlib_lib.fd](../../../source/zlib_lib.fd).
