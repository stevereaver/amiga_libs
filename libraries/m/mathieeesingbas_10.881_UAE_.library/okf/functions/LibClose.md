---
type: Function
title: LibClose
description: IEEE single routine at LVO -12.
---

# LibClose — LVO -12

`a6 = lib base -> d0 = seglist/0`

lib_OpenCnt--; if it reached zero and LIBF_DELEXP is set, unlinks ln_Succ/ln_Pred and runs the shared remove+free tail (FreeMem of base-negsize, size negsize+possize, ExecBase reloaded from absolute 4).

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
