---
type: Function
title: LibOpen / LibClose / LibExpunge / stubs
description: Standard library vectors (-6/-12/-18) and the four stub slots.
---

# LibOpen (-6, code+0xb4)

`lib_OpenCnt++`, clear `LIBF_DELEXP`, return base in d0.

# LibClose (-12, code+0xc2)

`lib_OpenCnt--`; if still nonzero or DELEXP clear, return 0 via a word
branch to the code+0 stub; otherwise falls through into LibExpunge.

# LibExpunge (-18, code+0xd4)

If `lib_OpenCnt` nonzero: set DELEXP, return 0.  Otherwise:
save d2/a5/a6, seglist → d2, SysBase from `4.W`, `Remove(lib)`,
`FreeMem(lib - negSize, negSize + posSize)`, return seglist.

# Stubs (-24 / -42 / -48 / -60)

All four point at the `moveq #0,d0; rts` at code+0 via negative
functab offsets — return 0, no state is freed or reset anywhere.
