# mathtrans_43.6(020_030_FPU).library

- **Binary:** `binary/mathtrans_43.6(020_030_FPU).library` — 2,488 bytes, single CODE hunk (0x974 B) + DREL16 + END.
- **ID string:** ` mathtrans.library_6888x_version 43.6 (8.4.2001) © 1997-2001 Jess Sosnoski`
- **What it is:** FPU-backed replacement for the Amiga `mathtrans.library` API. Every public vector expands the packed "trans" argument format to IEEE single, runs a single 6888x `f<op>.s`, and packs the result back. Requires `AFF_68881` at init.
- **Reconstruction:** pure m68k asm (`source/mathtrans.s`) + post-link `drel16.py` fixup converting ld's RELOC32 tail to the original's DREL16 format. **Whole file byte-identical** (MD5 `95f979ff0a7ba13754c70c92ffc5da0e`).
- **Verification:** `work/oracle.py` runs both binaries under machine68k — lifecycle identical, the integer-only vectors (SPTieee/SPFieee) identical on test vectors. FPU stubs are byte-identical code; machine68k has no FPU so math ops are covered structurally only.

## Layout
- `source/` — `mathtrans.s`, `drel16.py`, `Makefile`
- `okf/functions/vectors.md` — vector table, per-stub structure
- `okf/structures/layout.md` — hunk map, library data area, trans format
- `okf/findings/defects.md` — quirks/defects reproduced
- `okf/log.md` — work log
