---
type: Function
title: IEEEDPFieee
description: IEEE double routine at LVO -108.
---

# IEEEDPFieee — LVO -108

`double IEEEDPFieee(d0 parm)`

(single) -> double; shipped code does `fmove.s d0,fp0` — the single in
d0 is widened to a double in fp0, then `fmove.d fp0,-(sp)` and popped
into d0/d1.  A genuine conversion, not the integer reinterpretation an
earlier note claimed.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
