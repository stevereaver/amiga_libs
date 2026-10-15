---
type: Function
title: LibOpen / LibClose / LibExpunge / stubs
description: Standard library vectors (-6/-12/-18) and the four shared-null slots.
---

# LibOpen (-6, code+0x17a)

`lib_OpenCnt++`, clear `LIBF_DELEXP`, return base in d0.

# LibClose (-12, code+0x188)

`lib_OpenCnt--`; if still nonzero or DELEXP clear, byte-branch to the
shared `moveq #0,rts` at code+0x20a; otherwise falls through into
LibExpunge.

# LibExpunge (-18, code+0x196)

If `lib_OpenCnt` nonzero: set DELEXP, branch to the shared null.
Otherwise: push seglist and lib, SysBase from `4.W`, `Remove(lib)`;
peek the pushed lib into a0/a1, `FreeMem(lib - negSize, negSize +
posSize)`; pop lib into a6, pop seglist into d0 (return value).

# Shared null (-24 / -42 / -48 / -60 → code+0x20a)

All four slots point at XpksPackChunk's success tail
(`moveq #0,d0; rts`) rather than the entry stub at code+0 — return 0,
nothing is freed or reset.
