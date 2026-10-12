# xpkHFMN_1.4_000_.library — OKF index

- Binary: `binary/xpkHFMN_1.4(000).library` (1,936 bytes, single 3E9 hunk;
  md5 20c8ebb1f13bbbb7823ec38fabba6f53)
- Identity: `$VER: xpkHFMN V1.4 (1 Oct 2013) by Martin Hauner`
- Kind: XPK sublibrary, "Fast Dynamic Huffman Statistic Compression"
  (ID `HFMN`, flags 9)
- CPU: 68000 — same V1.4 source as `xpkHFMN_1.4_020_` compiled for the
  plain 68000; NO `AttnFlags` gate in LibInit, no BFINS/BFEXTU
  (shift-based emit/decode instead)
- Reconstruction: `source/xpkHFMN.c` (codec + lifecycle, shared with the
  020 sibling), `source/xpkHFMN_lib.s` (RomTag/inittab/datatab/
  descriptor/init, no CPU gate), `source/genfunctab.py` +
  `functab_stub.s` (two-pass word-offset functab); built `-m68000`
- Verification: 9/9 compressible host round-trips; pack streams
  byte-identical to the verified 020 reconstruction on 10/10 inputs;
  independent Python decoder reproduces input; header bytes,
  descriptor and mode block byte-exact vs the original.

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
