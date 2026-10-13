# xpkHUFF.library 0.64 — OKF index

XPK compression sublibrary: **static-order Huffman** — builds a
fresh canonical-ish Huffman tree per chunk (sorted-list pairwise
merge, tie-broken toward the last equal-count leaf), serialises
the code table as `len-1` + MSB-first code bytes, then emits an
MSB-first bit stream.  Optional password layer scrambles every
byte after the 6-byte header.  AUTOINIT library, **absolute-
longword** functab (not the word-offset form used by siblings).

Early-generation (1997) codec — entirely different code base
from the completed xpkHUFF 1.0(000) rebuild (2013), though the
wire format is the same family.

- Binary: `binary/xpkHUFF_0.64.library` — 2284 bytes, m68000,
  id string `xpkHUFF 0.64 (01.04.1997)\r\n`.
- Reconstruction: `source/` — C core (`xpkHUFF.c`, with a
  `HOST_TEST` path) + AutoInit glue (`xpkHUFF_lib.s`).
- Library name `xpkHUFF.library`, XPK id `'HUFF'`,
  flags `0x2009`, single mode record (upto 100, DefMode 50,
  chunk 0x3f, PackMem 0x7324 / UnpackMem 0x1141a).

## Verification status

Byte-identical pack streams vs the original on the full corpus
(16 standard tests + 5 skewed 4-16k inputs + >64k boundary
inputs), identical unpack output (including wild-read U.B.
corners), identical return codes on every error path, identical
lifecycle behaviour including the ExecBase+14 DELEXP bug.
Oracle: `work/oracle.py` (machine68k), `work/verify.py`,
`work/lifecycle.py`.

## Contents

- `functions/vectors.md` — LVO table + entry points
- `functions/packer.md` — pack algorithm
- `functions/unpacker.md` — unpack algorithm
- `structures/workmem.md` — pack/unpack workmem, descriptor,
  stream format, password hash
- `findings/defects.md` — shipped quirks and bugs
- `log.md` — RE session log
