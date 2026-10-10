---
type: Function
title: LibExpunge (-18)
description: If open count >0 sets LIBF_DELEXP and returns 0; otherwise Remove()s the library node, runs exit funcs, FreeMems the library segment.
isa: m68k
---

# LibExpunge (-18)

If open count >0 sets LIBF_DELEXP and returns 0; otherwise Remove()s the library node, runs exit funcs, FreeMems the library segment.

Source: [source/func.c](../../../source/func.c). Wrapper naming and register args per [zlib_lib.fd](../../../source/zlib_lib.fd).
