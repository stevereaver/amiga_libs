---
type: Function
title: GZ_FileLength (-138)
description: a0=gzhandle. Seeks file to -4, FReads 4 bytes, restores pos; returns little-endian ISIZE (uncompressed length mod 2^32). Only valid for real gzip members.
isa: m68k
---

# GZ_FileLength (-138)

a0=gzhandle. Seeks file to -4, FReads 4 bytes, restores pos; returns little-endian ISIZE (uncompressed length mod 2^32). Only valid for real gzip members.

Source: [source/func.c](../../../source/func.c). Wrapper naming and register args per [zlib_lib.fd](../../../source/zlib_lib.fd).
