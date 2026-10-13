# xpksqsh_1.10(older).library — OKF index

- Binary: `binary/xpksqsh_1.10(older).library` (2,232 bytes, single 3E9
  hunk of 2,100 bytes code — **truncated**: ends right at the HUNK_END
  type word, missing its trailing size longword)
- Identity: `xpkSQSH 1.10 (6.3.94)` by John Hendrikx; libname
  `xpkSQSH.library`, XPK ID `SQSH`
- **Near-twin of xpkSQSH_1.00**: the entire 2,100-byte code hunk is
  byte-identical to `xpkSQSH_1.00.library` except metadata — idstring
  ("1.10 (6.3.94)" vs "1.00 (13.10.93)", padded to the same field),
  datatab lib revision (10 vs 0), longname ("Squash 1.10" vs
  "Squash 1.0"). All executable code, tables, descriptors identical.
- **Prefix of xpkSQSH_1.10.library**: bytes 0..2231 equal the full
  2,936-byte 1.10 binary, which appends a 704-byte overlay after
  HUNK_END (dead data to the Amiga loader).
- Reconstruction: `source/xpkSQSH.c` is verbatim the 1.00 codec;
  `source/xpkSQSH_lib.s` differs only in idstr/revision/longname.
- Codec: identical to 1.00 — see
  `libraries/xpkSQSH_1.00.library/okf/` for the full algorithm,
  structure and defect analysis. LZ + signed-delta literals for
  8-bit sound, litpress>7 inverted mode, dual-slot hash chain.
- Verification (machine68k, M68020): 16/16 sweep streams byte-identical
  to the original, all round-trips pass, header/descriptor/rev=10 all
  match.

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
