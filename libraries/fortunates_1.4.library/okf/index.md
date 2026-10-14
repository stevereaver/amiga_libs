# fortunates 1.4.library — OKF index

## Identity

| field    | value                                                              |
|----------|--------------------------------------------------------------------|
| libname  | `fortunates.library`                                               |
| version  | 1.4 — `"fortunates 1.4 (08.06.97)"`                                |
| size     | 2976 bytes                                                         |
| format   | hunk: CODE(2516 B) + DATA(16 B) + BSS(152 B)                       |
| resident | AUTOINIT (`rt_Flags = 0x80`), rt_Init -> h0+0xda InitTable         |
| purpose  | "Fortunes" image utility library: FORM/RGB8 image loader (BMHD/BODY parser, PackBits-style row/column decompressors, bitplane interleaver), ReqTools requester glue for picking a fortune/image path, DOS file I/O, and an ILBM BODY/FORM writer (`_makeimg`). |

## Reconstruction

- **Approach**: pure 68k assembly, byte-identical target (SAS/C-style
  compiled C: `movel a6,sp@()` libbase stashes, exec/dos calls through
  BSS-cached library bases, `moveal 4:w` SysBase copies).
- **Source**: `source/fortunates_h0.s` (all code + embedded RomTag /
  InitTable / functab / datatab / strings), `source/fortunates_h1.s`
  (16-byte DATA hunk: three longs), `source/fortunates_h2.s`
  (152-byte BSS), `source/Makefile` + generated `hunks.x`,
  `source/fixup.py` (restores the original RELOC32 grouping and flips
  the h2 record back to HUNK_BSS).
- **Result**: `fortunates.library` byte-identical to the original
  (MD5 `05622c0c9f63d78bd77e0c7dd54925e1`).
- **Runtime**: `work/oracle.py` — identical traces for AUTOINIT init
  (9 OpenLibrary calls + header fields), Open/Close/Expunge lifecycle,
  AvailMem sum, BSS pointer, tag-list lookup hit/miss, FORM loader
  success + open-fail paths, ReqTools requester path, and the pure
  helpers (shiftbit/penmetric/unpackrow/unpackcol/interleave/
  interleave2/makebody/makeimg) — original vs rebuild logs equal.

## Files

- `functions/vectors.md` — vector/LVO table and helper semantics.
- `structures/layout.md` — hunk map, InitTable/datatab, library + BSS
  layout, relocation groups.
- `findings/quirks.md` — quirks and inconsistencies.
- `log.md` — work log.

## Status

Complete — byte-identical and runtime-identical (oracle-verified).
