---
type: Function
title: IEEEDPFieee
description: IEEE double routine at LVO -108.
---

# IEEEDPFieee — LVO -108

`double IEEEDPFieee(d0 parm)`

(single) -> double; shipped code does fmove.l d0,fp0 -- loads d0 as a LONG INTEGER then fmove.d out. See findings: the argument is interpreted as an integer, not a single float.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
