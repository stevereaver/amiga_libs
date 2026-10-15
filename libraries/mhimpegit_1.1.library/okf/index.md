# mhimpegit.library 1.1

MHI-style decoder-control library for MPEGit audio hardware modules,
fronting `prelude.library` (>= 5.6). Built with SAS/C; two hunks:
CODE 2728 B + near-data DATA hunk (16 B allocated / 4 B initialized)
holding the four library-base globals. DREL16 (`0x3f7`) relocations.

- Original MD5: `9857940b35d4b8e1b899a5a42469eed2` (3012 bytes)
- Reconstruction: `source/mhimpegit_h0.s` + `source/mhimpegit_h1.s`
  (byte-identical; `make` rebuilds, `fixup.py` rewrites the relocation
  tail to the original DREL16 format)
- Runtime oracle: `work/oracle.py` — RUNTIME-IDENTICAL

See `functions/vectors.md`, `structures/layout.md`,
`findings/quirks.md`, `log.md`.
