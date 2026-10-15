# Rebuild delta

**2026-10-15: none.**  `make` assembles the verbatim
`xpkRLEN_h0.s` transcription — the rebuild is byte-identical
(md5 `e0f7d2275b0331a7a0c86f88123671ed`).  The original's RELOC32
tail is already ascending, matching GNU ld's natural order, so no
post-link fixup is needed (unlike 1.4 whose tail is descending).

Historical note — the earlier C model (still `make cmodel`): rebuilt
via m68k-amigaos-gcc -m68000, the C version had matching
RomTag/functab/XpkInfo data but different codegen and hunk layout.
