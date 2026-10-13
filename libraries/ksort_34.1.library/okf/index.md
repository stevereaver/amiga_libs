# ksort.library 34.1 — OKF index

Tiny SAS/C-era utility library exporting **seven recursive
quicksort variants** over bytes/words/longs, signed and
unsigned, plus a case-insensitive string-pointer sort that uses
a bundled `stricmp` comparator.  Part of the "AK" library
family (`ak.library`, `ak_gen*.library`, `akcc*.library` in
this repo); the RareOldLibs.lha readme calls it "customized
Quicksort algorithms".  No public headers survive — the entry
names below are descriptive.

- Binary: `binary/ksort_34.1.library` — 2300 bytes, m68000,
  id string `ksort.library 34.1 (01 Jan 93)\r\n`.
- Reconstruction: `source/` — C sorts (`ksort.c`) + AutoInit
  glue (`ksort_lib.s`).

## Hunk layout (original)

Four hunks: `CODE 536B` (RomTag, InitTable, functab, datatab,
LibInit/Open/Close/Expunge, null stub, name/id/lib strings) +
`BSS 64B` (SysBase + DOS/Intuition/Gfx bases) +
`CODE 1400B` (7 sort wrappers + 7 workers + jmp-stub to
comparator) + `CODE 60B` (stricmp).  42 hunk0 relocations
(20 self, 15 into BSS, 7 into hunk2), 1 hunk2→hunk3 reloc.

Imports `dos.library`, `intuition.library`, `graphics.library`
at init — opened but **never used** (vestigial framework
boilerplate).

## Vectors (11, absolute-long functab)

| LVO | Target   | Function                              |
|-----|----------|---------------------------------------|
| -6  | h0+0x150 | LibOpen (opencnt++, clear DELEXP)     |
| -12 | h0+0x15e | LibClose                              |
| -18 | h0+0x172 | LibExpunge (see defects)              |
| -24 | h0+0x214 | null stub (`moveq #0,d0; rts`)        |
| -30 | h2+0x000 | quicksort signed bytes                |
| -36 | h2+0x0a8 | quicksort unsigned bytes              |
| -42 | h2+0x150 | quicksort signed words                |
| -48 | h2+0x222 | quicksort unsigned words              |
| -54 | h2+0x2f4 | quicksort signed longs                |
| -60 | h2+0x3bc | quicksort unsigned longs — DEFECTIVE  |
| -66 | h2+0x484 | quicksort string ptrs (stricmp)       |

All sorts take `(array:d0, count:d1)`, sort `a[0..count-1]` in
place, and return unspecified d0 residue.

## Verification status

machine68k oracle (`work/oracle.py`): identical library header,
identical lifecycle (incl. the a5-opencnt and addr-0 expunge
quirks), byte-identical sorted output on 20 directed cases +
large randomized sweep across all six numeric variants and the
string sort — including the u32 worker's wild-write corruption
path (identical displaced elements below the array base).

## Files

- `functions/vectors.md` — vector/LVO details + ABI
- `functions/sorts.md` — worker algorithm, compare flavors,
  per-variant differences, the u32 index-unsignedness defect
- `structures/layout.md` — hunk map, lib data area, BSS block
- `findings/defects.md` — expunge wild read/write, name-string
  CloseLibrary, u32 unsigned-index corruption
- `log.md` — work log
