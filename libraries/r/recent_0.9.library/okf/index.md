# recent 0.9.library — OKF index

## Identity

| field    | value |
|----------|-------|
| libname  | `recent.library` |
| version  | 0.9 — `"recent.library 0.9 (September 20, 1999)"` |
| size     | 2996 bytes |
| format   | hunk: single CODE(2848 B); 24 self-relocations |
| resident | AUTOINIT (`rt_Flags = 0x80`), rt_Init -> h0+0x74 InitTable |
| purpose  | MRU / "recent documents" manager. Keeps keyed groups of recent-file records (full path + basename pointer + DateStamp), persists them to `ENVARC:Recent/<name>` files with `RCNT` magic, and can build a GadTools menu (NewMenu array -> CreateMenusA) out of a group. Deps: `dos.library` (v33+) and `gadtools.library` (v36+). |

## Reconstruction

- **Approach**: pure 68k assembly, byte-identical target. SAS/C-style
  compiled C — bases cached in library-private fields (lib+0x26 = dos,
  lib+0x2a = gadtools), heavy `movel #imm` / explicit disp16-zero forms.
- **Source**: `source/recent_h0.s` (all code + RomTag / InitTable /
  functab / datatab / strings / embedded `ENVARC:Recent/` + `RCNT`
  data), generated first via `work/genasm.py` (Capstone) then hand-
  corrected for encoding exactness; `source/Makefile`,
  `source/fixup.py` (rewrites the tail into the original
  `{count, hunk, offs}`-order RELOC32 block).
- **Result**: `recent.library` byte-identical to the original
  (MD5 `34928dfc801fd2b4e63bc67d1a362020`).
- **Runtime**: `work/oracle.py` — identical traces over init, Open/
  Close/Expunge lifecycle, `_load` miss+fixture, `_free`, `_touch`
  new/existing/full/nolock/badkey, `_addblk` new+dup, `_getblk`,
  `_setmax` grow+shrink, `_menu` (NewMenu + CreateMenusA), `_save`
  serialization, `_savefree`, deferred expunge.

## Vector summary

-12 Open, -18 Close, -24 Expunge, -30 null-stub, -36 `_load`,
-42 `_free`, -48 `_touch`, -54 `_addblk`, -60 `_getblk`, -66 `_save`,
-72 `_setmax`, -78 `_menu`, -84 `_savefree`. See `functions/vectors.md`.
