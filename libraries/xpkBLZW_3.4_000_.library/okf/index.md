# xpkBLZW.library 3.4 — OKF Index

**Binary:** `xpkBLZW_3.4(000).library` (0x6ec-byte code hunk, 1916-byte file)
**ID string:** `$VER: xpkBLZW V3.4 (1 Oct 2013) by Bryan Ford`
**Library name:** `xpkBLZW.library` — version 3, revision 4
**Family:** XPK compression sublibrary, same skeleton as
`xpkRDCN`/`xpkZENO`/`xpkFAST` but a Unix-`compress`-style LZW codec:
9..15 bit codes selected by mode, MSB-first bit packing, CLEAR/END/
width++ markers, ratio-checkpoint dictionary resets.

## Layout

- `functions/vectors.md` — LVO map, functab structure
- `structures/layout.md` — XpkSubParams, library base, XpkInfo
  descriptor + 7-entry mode chain, work-buffer fields
- `algorithms/format.md` — stream format, decoder walk
- `algorithms/packer.md` — hash packer, emit machinery, ratio
  checkpoints, CLEAR restart
- `findings/defects.md` — shipped quirks/defects reproduced

## Verification

- Header/RomTag/datatab: byte-identical modulo relocated pointers;
  `rt_EndSkip` is a literal `dc.l 0` (not a relocated pointer).
- XpkInfo descriptor + 7 mode descriptors + strings: byte-identical
  modulo relocated pointers.
- Packer: C output decodes byte-exact via an independent Python
  decoder modelled on the disassembly (200 KB stream containing
  19 width++ markers and 3 CLEAR markers).
- Decoder: byte-exact on 16 streams produced by an independent
  Python encoder (all widths 9/12/15, KwKwK-heavy and dict-full
  streams).
- Small inputs: pack returns -17 whenever the output budget
  (inlen&~31)-8 is exceeded — faithful; see defects.
