# xpkZENO.library 1.2 — OKF index

XPK compression sublibrary: **Zeno Ries LZW** — a hash-probed
LZW-family codec with 12/13/14-bit dictionary modes, MSB-first
bit packing, an adaptive dictionary-reset heuristic and an
optional password hash in the stream header.  AUTOINIT library,
word-offset functab.

- Binary: `binary/xpkZENO_1.2(000).library` — 1800 bytes, m68k,
  `$VER: xpkZENO V1.2 (1 Oct 2013) by Gerhard Tuenkler`.
- Reconstruction: `source/` — C core (`xpkZENO.c`) + AutoInit glue
  (`xpkZENO_lib.s`, generated `functab.s`, `endmodule.s`).
- Library name `xpkZENO.library`, XPK id `'ZENO'`,
  flags `0xa009`, three modes "12 bit" / "13 bit" / "14 bit"
  (upto 33 / 66 / 100; default mode 100).

## Contents

- `functions/vectors.md` — LVO table + entry points
- `functions/packer.md` — pack algorithm (hash dictionary,
  bit emitter, width growth, adaptive reset)
- `functions/unpacker.md` — unpack algorithm (bit reader,
  dictionary expansion, KwKwK, reset handling)
- `structures/workmem.md` — pack/unpack workmem maps + descriptor
- `findings/defects.md` — shipped quirks and bugs
- `log.md` — RE session log
