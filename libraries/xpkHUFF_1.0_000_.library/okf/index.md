# xpkHUFF.library 1.0 — OKF index

XPK compression sublibrary: **dynamic Huffman** coding over raw
input bytes, with an optional **password layer** (name hash +
chained-XOR scramble).  AUTOINIT library, word-offset functab.

- Binary: `binary/xpkHUFF_1.0(000).library` — 1796 bytes, m68k,
  `$VER: xpkHUFF V1.0 (1 Oct 2013) by Marc Zimmerman`.
- Reconstruction: `source/` — C core (`xpkHUFF.c`) + AutoInit glue
  (`xpkHUFF_lib.s`, generated `functab.s`, `endmodule.s`).
- Library name `xpkHUFF.library`, XPK id `'HUFF'`,
  flags `0x2009` (password support bit 0x2000), one mode
  "dynamic" (upto 100, packmem 0x3208, unpackmem 0x1004).

## Contents

- `functions/vectors.md` — LVO table + entry points
- `functions/packer.md` — pack algorithm (histogram, sorted-list
  Huffman, table emit, bit emitter, scramble)
- `functions/unpacker.md` — unpack algorithm (hash verify,
  descramble, trie build, fast table, bit walk)
- `structures/workmem.md` — pack/unpack workmem maps + descriptor
- `findings/defects.md` — shipped quirks and bugs
- `log.md` — RE session log
