# xpkHFMN_1.4_020_.library — OKF index

- Binary: `binary/xpkHFMN_1.4(020).library` (1,748 bytes, single 3E9 hunk)
- Identity: `$VER: xpkHFMN V1.4 (1 Oct 2013) by Martin Hauner`
- Kind: XPK sublibrary, "Fast Dynamic Huffman Statistic Compression" (ID `HFMN`, flags 9)
- CPU: 68020+ — init gates on `AttnFlags & AFB_68020`; original used BFINS/BFEXTU
- Reconstruction: `source/xpkHFMN.c` (codec + lifecycle),
  `source/xpkHFMN_lib.s` (RomTag/inittab/datatab/descriptor/init),
  `source/genfunctab.py` + `functab_stub.s` (two-pass word-offset functab)
- Verification: 9/9 compressible host round-trips; encoder byte-exact vs
  independent Python model (incl. the ADDX pad-'1' quirk); independent
  Python decoder reproduces input; descriptor/mode block byte-exact.

See `functions/vectors.md`, `structures/layout.md`, `findings/defects.md`,
`log.md`.
