# xpkZENO.library 1.1 — OKF index

XPK compression sublibrary: **Zeno LZW** — hash-probed
LZW-family codec with 12/13/14-bit dictionary modes, MSB-first
bit packing, adaptive dictionary-reset heuristic and an optional
password hash in the stream header.  AUTOINIT library,
word-offset functab.  Earlier, substantially different
implementation than the completed ZENO 1.2 rebuild (not a
trivial sibling — different allocations, header padding,
decoder bit reader, free routines and LibInit).

- Binary: `binary/xpkZENO_1.1.library` — 2260 bytes, m68k,
  `$VER: xpkZENO 1.1` (id string `xpkZENO 1.1\r\n`).
- Reconstruction: `source/` — C core (`xpkZENO.c`) + AutoInit
  glue (`xpkZENO_lib.s`, generated `functab.s`).
- Library name `xpkZENO.library`, XPK id `'ZENO'`,
  flags `0xa009`, three linked modes "12 bit" / "13 bit" /
  "14 bit" (upto 33 / 66 / 100; DefMode 50) plus a DEAD,
  unlinked "15 bit" mode record in the older 30-byte format.

## Contents

- `functions/vectors.md` — LVO table + entry points
- `functions/packer.md` — pack algorithm
- `functions/unpacker.md` — unpack algorithm
- `structures/workmem.md` — pack/unpack workmem + descriptor +
  stream layout
- `findings/defects.md` — shipped quirks and bugs
- `log.md` — RE session log
