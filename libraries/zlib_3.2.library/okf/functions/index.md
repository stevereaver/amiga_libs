---
type: Index
title: Functions — zlib.library 3.2
---

# Exported functions / LVO entries

Vector table (`FUNCTABLE` in hunk 3): 24 `DC.L` entries + `-1` terminator.
Entries 0-3 are the standard library vectors; bias = 30.

| # | LVO | Name | ISA | Args |
|---|-----|------|-----|------|
| 0 | -6 | [LibOpen](LibOpen.md) | 68k | — |
| 1 | -12 | [LibClose](LibClose.md) | 68k | — |
| 2 | -18 | [LibExpunge](LibExpunge.md) | 68k | — |
| 3 | -24 | LibReserved | 68k | returns nothing (empty) |
| 4 | -30 | [GZ_Open](GZ_Open.md) | 68k | a0,d0,d1,d2 |
| 5 | -36 | [GZ_OpenFromFH](GZ_OpenFromFH.md) | 68k | a0,d0,d1,d2 |
| 6 | -42 | [GZ_Close](GZ_Close.md) | 68k | a0 |
| 7 | -48 | [GZ_Read](GZ_Read.md) | 68k | a0,a1,d0 |
| 8 | -54 | [GZ_FGetS](GZ_FGetS.md) | 68k | a0,a1,d0 |
| 9 | -60 | [GZ_FGetC](GZ_FGetC.md) | 68k | a0 |
| 10 | -66 | [GZ_Write](GZ_Write.md) | 68k | a0,a1,d0 |
| 11 | -72 | [PPCGZ_Open](PPCGZ_Open.md) | PPC | explicit libbase+args |
| 12 | -78 | [PPCGZ_OpenFromFH](PPCGZ_OpenFromFH.md) | PPC | |
| 13 | -84 | [PPCGZ_Close](PPCGZ_Close.md) | PPC | |
| 14 | -90 | [PPCGZ_Read](PPCGZ_Read.md) | PPC | |
| 15 | -96 | [PPCGZ_FGetS](PPCGZ_FGetS.md) | PPC | |
| 16 | -102 | [PPCGZ_FGetC](PPCGZ_FGetC.md) | PPC | |
| 17 | -108 | [PPCGZ_Write](PPCGZ_Write.md) | PPC | |
| 18 | -114 | [GZ_CompressMem](GZ_CompressMem.md) | 68k | a0,d0,a1,d1,d2,d3,a2 |
| 19 | -120 | [GZ_DecompressMem](GZ_DecompressMem.md) | 68k | a0,d0,a1,d1 |
| 20 | -126 | [PPCGZ_CompressMem](PPCGZ_CompressMem.md) | PPC | |
| 21 | -132 | [PPCGZ_DecompressMem](PPCGZ_DecompressMem.md) | PPC | |
| 22 | -138 | [GZ_FileLength](GZ_FileLength.md) | 68k | a0 |
| 23 | -144 | [PPCGZ_FileLength](PPCGZ_FileLength.md) | PPC | |

Notes:

- `GZ_*` LVOs land on m68k code in hunk 0; `PPCGZ_*` LVOs land on PPC code in
  hunk 1 — calling them requires a WarpOS kernel switching CPU context.
- `PPCGZ_*` prototypes take `struct Library *` as the explicit first argument
  (see `func_ppc.c` / `include/clib/zlib_protos.h` call stubs).
- `openmode` args are AmigaDOS modes (`MODE_OLDFILE`=1005 → 'r',
  `MODE_NEWFILE`=1006 → 'w'); `strategy` maps to gzip mode chars
  0='d',1='f',2='h'; `level` is clamped to 0..9.
