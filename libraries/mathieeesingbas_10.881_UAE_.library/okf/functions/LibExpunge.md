---
type: Function
title: LibExpunge
description: IEEE single routine at LVO -18.
---

# LibExpunge — LVO -18

`a6 = lib base -> d0 = seglist/0`

If lib_OpenCnt != 0: sets LIBF_DELEXP and returns 0. Otherwise unlinks the node and runs the free tail, returning the stashed seglist.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
