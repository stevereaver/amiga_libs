---
type: Finding
title: Unusual library naming
description: Library name "_asl.library" and directory "_asl._40.6" vs the standard asl.library/asl_lib.fd.
timestamp: 2026-10-10T18:00:00Z
---

# Unusual library naming

The resident name is `_asl.library` (with leading underscore) and the
id string is `$VER: _asl.library 40.6`.  The matching NDK interface
file is `asl_lib.fd` (base `_AslBase`).  The strings "_asl.library"
and "asl.library" coexist deliberately: the InitStruct points
libbase+0x26 at `_libname+1`, i.e. at the name without the
underscore, which the relay passes to OpenLibrary.  The underscore
prefix is presumably a private-API convention of the shipping
product.
