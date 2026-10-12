# xpkFAST.library 1.2 — OKF index

XPK compression sublibrary: **"FAST" aka WOOP / LZRW++** by
Christian von Roques — an LZ77-family codec with a 4 KB window,
max match length 18, literals written forward and
control/match words written *backward* into the same output
buffer.  Two packers share one stream format: a greedy
single-candidate "speedy" packer (mode < 79) and a hash-chain
"crawling" packer (mode >= 79).  AUTOINIT library, word-offset
functab.

- Binary: `binary/xpkFAST_1.2(000).library` — 1844 bytes, m68k,
  `$VER: xpkFAST V1.2 (1 Oct 2013) by Christian von Roques`.
- Reconstruction: `source/` — C core (`xpkFAST.c`) + AutoInit glue
  (`xpkFAST_lib.s`, generated `functab.s`, `endmodule.s`).
- Library name `xpkFAST.library`, XPK id `'FAST'`,
  flags `0x8009`, two modes "speedy" (upto 78) / "crawling"
  (upto 100; default 100).

## Contents

- `functions/vectors.md` — LVO table + entry points
- `algorithms/format.md` — stream layout, tokens, control words,
  sentinel mechanics, tail compaction
- `algorithms/packers.md` — speedy + crawling match search
- `structures/workmem.md` — XpkSubParams + workmem maps + descriptor
- `findings/defects.md` — shipped quirks and bugs
- `log.md` — RE session log
