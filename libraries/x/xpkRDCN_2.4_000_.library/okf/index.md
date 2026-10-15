# xpkRDCN.library 2.4 — OKF Index

**Binary:** `xpkRDCN_2.4(000).library` (0x6f0-byte code hunk)
**ID string:** `$VER: xpkRDCN V2.4 (1 Oct 2013) by Niklas Sjoeberg`
**Library name:** `xpkRDCN.library` — version 2, revision 4
**Family:** XPK compression sublibrary ("Ross Data Compression V2.4"),
same skeleton as `xpkZENO` / `xpkFAST` but a different bitstream:
LZ77 + RLE hybrid with 16-token BE control words.

## Layout

- `functions/vectors.md` — LVO map, functab structure
- `structures/workmem.md` — XpkSubParams, library base, XpkInfo
  descriptor + mode chain, pack work memory
- `algorithms/format.md` — bitstream token formats, decoder
- `algorithms/packers.md` — speedy + crawling packers
- `findings/defects.md` — shipped quirks/defects reproduced

## Verification

- Header (0x00–0xac): byte-identical modulo relocated pointers.
- XpkInfo descriptor + mode chain + strings: byte-identical modulo
  relocated pointers.
- Speedy packer: byte-exact output vs an independent Python model of
  the disassembly (8 test streams).
- Crawling packer: byte-exact output vs an independent model
  (10 test streams).
- Decoder: all produced streams decode correctly via an independent
  Python decoder; C round-trips verified on 20+ inputs.
