# config 1.0.library — OKF index

## Identity

| field    | value |
|----------|-------|
| libname  | `config.library` |
| idstring | `config 1.0 (12.10.96)` |
| copyright| `Copyright (C) 1996, Adam Dawes` |
| version  | **3.0** (`lib_Version=3`, RomTag `rt_Version=3`) — the id string says "1.0"; see findings |
| size     | 2956 bytes |
| format   | hunk: h0 CODE 2404 B + h1 DATA 340 B (table says 344 B — quirk) |
| resident | AUTOINIT (`rt_Flags=0x80`), RomTag + InitTable + datatab + functab all live in the **DATA hunk** (h1+0xa4 / h1+0x118 / h1+0xbe / h1+0x128) |
| purpose  | INI-style `[section]`/`key = value` config file reader/writer. Deps: `dos.library`, `intuition.library`, `graphics.library` (all v37; the intuition/graphics bases are opened and stored but never used) |

## Reconstruction

- **Approach**: 68k assembly, byte-identical target. SAS/C-compiled C
  with small-data model — `a4 = h1+0x7ffe`, globals/dep bases/strings
  reached via `a4@(-32690)`-style offsets into h1.
- **Source**: `source/config_h0.s` (all code, generated via Capstone
  from `work/gen_h0.s` then hand-corrected), `source/config_h1.s`
  (data hunk: strings, cells, RomTag, datatab, InitTable, functab),
  `source/Makefile`, `source/fixup.py` (restores original RELOC32
  group order + the h1 table/body size quirk).
- **Result**: `source/config.library` byte-identical —
  MD5 `3251b43caed885d8c0ba93b8ac1c3d1e` (orig and rebuild).
- **Runtime**: `work/oracle.py` — machine68k harness with stubbed
  exec (OpenLibrary/CloseLibrary/AllocVec/FreeVec/FreeMem/Remove/
  RemHead/AddTail/RawDoFmt) and dos (Open/Close/FGets/VFPrintf/
  StrToLong) plus an in-memory file store. Exercises init ok + dep
  failure, Open/Close/Expunge/ExtFunc incl. deferred expunge,
  SetStr (key replace, key append, new section, new file), SetNum,
  GetStr (hit/miss/tiny-buffer/missing-file), GetNum
  (hit/default/missing-file/unparseable). `orig.log` vs
  `rebuild.log`: **identical** (146 entries).

## Vector summary

functab @ h1+0x128, 8 absolute-long entries + 0xffffffff terminator:

| LVO | h0 off | fn      |
|-----|--------|---------|
| -6  | 0x738  | Open    |
| -12 | 0x750  | Close   |
| -18 | 0x778  | Expunge |
| -24 | 0x7da  | ExtFunc (null stub) |
| -30 | 0x000  | SetStr  |
| -36 | 0x2a0  | SetNum  |
| -42 | 0x2de  | GetStr  |
| -48 | 0x47c  | GetNum  |

Details in `functions/vectors.md`; structures in `structures/layout.md`;
defects/oddities in `findings/quirks.md`; work narrative in `log.md`.
