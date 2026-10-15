# xpkDMCU 41.0.library — OKF index

## Identity

| field    | value |
|----------|-------|
| libname  | `xpkDMCU.library` |
| version  | 41.0 — `"$VER: xpkDMCU.library 41.0 (15.04.98) © by André Osterhues"` |
| size     | 3152 bytes |
| format   | hunk: CODE h0 (0x1f6 longs = 2008 B) + DATA h1 (0xd4 longs = 848 B); RELOC32 |
| resident | AUTOINIT (`rt_Flags = 0x80`), packed RomTag at h1+0xe4, rt_Init -> h1+0 |
| purpose  | xpk sub-library: "DMCU — Dynamic Markov Coding Ultra" (arithmetic coding using Markov modelling). Standard xpk sublib skeleton plus a PowerPC bridge: init opens `ppc.library` v45, loads `LIBS:ppc/xpkDMCU.elf` and builds a small object pool via ppc LVOs; pack/unpack vectors dispatch to the PPC job when available, else a native 68k coder. |

## Reconstruction

- **Approach**: verbatim 68k assembly (Capstone disasm -> generator ->
  hand-corrected encodings), byte-identical target. SAS/C compiled C;
  `a4` = near-data base (`_gd` = h1+0, which is also the InitTable/
  functab/data-island region).
- **Source**: `source/xpkDMCU_h0.s` (code hunk with embedded strings),
  `source/xpkDMCU_h1.s` (DATA hunk: InitTable, long-offset functab,
  datatab, packed RomTag, dependency name strings, xpk info and
  size-label tables), `source/Makefile`, `source/fixup.py` (rewrites
  RELOC32 groups into the original's unsorted offset order).
  `work/genasm.py` produced the initial transcription.
- **Result**: `xpkDMCU.library` byte-identical to the original
  (MD5 `ac4a428b012daca082907b3286036c1b`, 3152 B).
- **Runtime**: `work/oracle.py` — identical traces over AUTOINIT init
  (full ppc.library open / ELF-load / object-pool protocol), Open x2,
  ExtFunc, info vector, free-vector, pack/unpack dispatch with no ppc
  job objects, deferred expunge, final close -> real expunge with ppc
  teardown + Remove + FreeMem(148).

## Vector summary

-6 Open, -12 Close, -18 Expunge, -24 null, -30 info table,
-36 pack dispatcher, -42 ppc-job free, -48 null, -54 unpack
dispatcher, -60 native unpack. See `functions/vectors.md`.

## Bundle

- `structures/layout.md` — hunks, InitTable, RomTag, `_gd` globals,
  xpk info tables
- `functions/vectors.md` — per-vector behavior
- `findings/quirks.md` — defects & reconstruction notes
