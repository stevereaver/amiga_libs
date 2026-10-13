# xpkSQSH_1.10.library — OKF index

- Binary: `binary/xpkSQSH_1.10.library` (2,936 bytes — single 3E9 hunk
  of 2,100 bytes code + reloc + HUNK_END at 0x8b8, then a 704-byte
  appended overlay the loader never sees)
- Identity: `xpkSQSH 1.10 (6.3.94)` by John Hendrikx; libname
  `xpkSQSH.library`, XPK ID `SQSH`, lib revision 10
- **Loadable image == xpksqsh_1.10(older) == xpkSQSH_1.00 code**:
  the first 2,232 bytes are byte-identical to the completed
  `xpksqsh_1.10(older)` twin — i.e. the 1.00 codec + 1.10 metadata
  (idstring, revision 10, "Squash 1.10" longname).
- **Overlay (bytes 2232..2935)**: dead data — sits after HUNK_END, no
  hunk header, and none of the 22 relocations or any vector/reference
  reach it. Disassembles as a hand-written `btst`-loop decoder
  fragment (68000-style, no bfins/bfextu): literal-run + width ladder
  + len/dist fields + `cmpw #31` litpress clamp + match copy, ending
  in what looks like a widtab-style table at 0xada. Likely a build
  artifact cat'ed from a related (68000) SQSH build.
- Reconstruction: `source/xpkSQSH.c` is verbatim the 1.00 codec;
  `source/xpkSQSH_lib.s` carries the 1.10 metadata. The overlay is
  documentation-only (not part of the loadable image).
- Codec: identical to 1.00 — see
  `libraries/xpkSQSH_1.00.library/okf/` for full algorithm/structures.
- Verification (machine68k, M68020): 16/16 sweep streams byte-identical
  to the original, all round-trips pass, rev=10 + descriptor match.

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
