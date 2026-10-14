# script 0.4.library — OKF index

## Identity

| field    | value                                                       |
|----------|-------------------------------------------------------------|
| libname  | `script.library`                                            |
| version  | 0.4 — `"script.library 0.4"` (no `$VER:` prefix)            |
| size     | 2636 bytes                                                  |
| format   | hunk: CODE(2292 B) + DATA(24 B) + CODE(88 B: functab+strings) |
| resident | AUTOINIT (`rt_Flags = 0x80`), rt_Init -> DATA+4 InitTable     |
| purpose  | ARexx/rexxsyslib companion library: per-context pooled named-entry store plus synchronous rexxsyslib round-trip helpers. Probes `rexxsyslib.library` per call and invokes several **private** (undocumented) rexxsyslib vectors. |

## Reconstruction

- **Approach**: pure 68k assembly, byte-identical target (vbcc-style
  compiled C: `subqw` frames, register args a0/a1/a2, libbase in a4 =
  `a6+48`, exec calls via `moveal 4:w/l,a6`).
- **Source**: `source/script_h0.s` (all code), `source/script_h1.s`
  (DATA: InitTable block), `source/script_h2.s` (functab + name/idstr),
  `source/Makefile` + generated `hunks.x`, `source/fixup.py`
  (restores the original linker's descending-grouped RELOC32 order).
- **Result**: `script.library` byte-identical to the original
  (MD5 `d9289bf0a34ecb9f9c42b88a275900fd`).
- **Runtime**: `work/oracle.py` — identical traces for init, header
  fields, the 20-byte DATA->lib+48 copy, Open/Close/deferred Expunge,
  ctx create/destroy, named-entry add/find, callback set/get, and the
  -30/-36 rexxsyslib round-trip incl. the status-40 length-mismatch
  path and the msg+252 stash/restore.

## Layout

- `functions/vectors.md` — vector/LVO map
- `structures/layout.md` — library private area, ctx, node
- `findings/quirks.md` — quirks, defects, undocumented calls
- `log.md` — work log
