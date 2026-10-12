# xpkFAST.library 1.06 — OKF index

XPK compression sublibrary: **"FAST V1.06 alias WOOP or LZRW++"**
by Christian von Roques — an LZ77-family codec with a 4 KB
window, max match length 18, literals written forward and
control/match words written *backward* into the same output
buffer.  Two packers share one stream format: a greedy
single-candidate "speedy" packer (mode < 80) and a hash-chain
"crawling" packer (mode >= 80).  AUTOINIT library, **LONG
absolute functab** (unlike 1.2's word-offset table).

This is an earlier release than the already-documented
`xpkFAST_1.2_000_.library` (see its okf/ bundle).  The wire
format is identical; the packers, lifecycle, and several
shipped quirks differ — see `findings/defects.md`.

- Binary: `binary/xpkfast_1.06.library` — 2128 bytes, m68k,
  `$VER: xpkFAST.library V1.06 (27-Jul-94)`.
- Reconstruction: `source/` — C core (`xpkfast.c`) + AutoInit
  glue (`xpkfast_lib.s`).
- Library name `xpkFAST.library`, XPK id `'FAST'`,
  flags `0x8009`, two modes "speedy" (upto 79) / "crawling"
  (upto 100; default 50 -> speedy).

## Contents

- `functions/vectors.md` — LVO table + entry points
- `algorithms/format.md` — stream layout, tokens, control words,
  sentinel mechanics, tail compaction
- `algorithms/packers.md` — speedy + crawling match search
- `structures/layout.md` — XpkSubParams, workmem maps, lib base,
  InitStruct/datatab quirk, descriptor
- `findings/defects.md` — shipped quirks and bugs
- `log.md` — RE session log
