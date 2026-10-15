---
type: Function
title: LibOpen
description: IEEE double routine at LVO -6.
---

# LibOpen — LVO -6

`a6 = lib base -> d0 = base`

Library Open vector. Writes FPCR = 0x10 (unconditional), then lib_OpenCnt++, clears LIBF_DELEXP (bit 3 of lib_Flags at offset 0x0e), returns a6.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
