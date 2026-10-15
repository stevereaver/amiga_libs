---
type: Structure
title: bitmap.library 1.4 base layout
---

# Library base (dataSize 0x9a = 154 bytes)

Standard `struct Library` fields then privates:

| off | content |
|-----|---------|
| +0x20 (32) | lib_OpenCnt |
| +0x22 (34) | ln_Succ reused -> seglist (set by initfn, Expunge ret) |
| +0x24 (36) | ln_Pred reused -> ln_Name shadow? initfn writes A0 |
| +0x30 (48) | **private data** — initfn copies 40B of hunk1 template here |
| +0x44 (68) | ptr to "graphics.library" string (inside the copied template; used by initfn OpenLibrary name arg) |
| +0x5c (92) | GfxBase (opened at init; read per call as `44(A4)` where A4=lib+48) |

## Hunk1 DATA template (44 bytes)

`+0` zero, `+4` 0x60 (unused InitStruct opcode?), `+8` functab ptr,
`+c` 0, `+10` initfn ptr, `+14..23` "graphics.library\0",
`+24` fixup-count 0, `+28` zero.  Copied verbatim to lib+0x30;
the embedded functab/initfn pointers in the copy are stale and
never re-fixed (fixup count reads hunk1+40 = 0).

## Relocations

CODE hunk: 48 same-hunk + 3 ->hunk1 (the initfn's
`lea SECSTRT_1` references and functab end marker region).
DATA hunk: 2 ->hunk0 (functab ptr at +8, initfn ptr at +0x10).
