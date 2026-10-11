# xpkSMPL.library 1.1 "SMPL"

Froehling XPK sublibrary: "Sample packer 1.1" -- dynamic Huffman
crunch with delta precoding (id string `xpkSMPL v1.1`).  1,568-byte
single-hunk library.

## Vectors
| LVO | Function |
|-----|----------|
| -6/-12/-18 | LibOpen / LibClose / LibExpunge |
| -24/-48 | null `moveq #0,d0/rts` (reserved / PackReset) |
| -30 | `XpksPackerInfo` -> static XpkInfo descriptor |
| -36 | `XpksPackChunk` -- dynamic-Huffman encoder |
| -42/-60 | `XpksPackFree` -- frees xsp_Sub[0] workmem |
| -54 | `XpksUnpackChunk` -- trie/fast-table decoder |

## Layout
- `70ff 4e75` entry stub, packed RomTag: AUTOINIT, ver 1, NT_LIBRARY
- InitTable dataSize 0x26; LibInit stores seglist at base+34
- datatab: ln_Type 9, name, flags 6, ver 1, rev 1, idstring
- word-offset functab: -1 marker, 10 word offsets, -1

## Stream format
- BE16 signature `0x0001`
- 256-entry code-length table, 4-bit nibble per symbol (0 = absent);
  len 15..30 encoded as `(len-31)&0xff` in 8 bits (first nibble 15,
  extension nibble = len-15); the emitted code itself follows each
  length
- delta-coded samples, one Huffman code each, MSB-first
- trailing 32-bit pad long (decoder may read up to 2 bytes past the
  end of the bit stream -- the pad covers it)

## Codec
- pack: histogram of 8-bit deltas -> sorted-list Huffman merge ->
  canonical codes -> nibble length table + data codes
- workmem 0x3800 bytes via AllocVec, held in xsp_Sub[0]:
  - wk+0x0000 pack slots / unpack binary trie (2048 B)
  - wk+0x0010 pack sorted-list head node
  - wk+0x0028 24-byte node arena (leaves + internals, 509 max)
  - wk+0x0800 1024-entry U16 fast decode table (10-bit prefixes)
  - wk+0x3010 256-byte code-length table
  - wk+0x3110 256-entry ULONG code-value table
  - wk+0x3510 256-entry UWORD delta histogram
- unpack: reads length table -> binary trie -> 1024-entry fast
  table over 10-bit prefixes (entry `steps<<8|sym` for short codes,
  `link-0x800` = negative trie-link for long codes, slow walk then
  continues via `btst`/`rol` bit test) -> delta accumulate.

## Source
`source/xpkSMPL.c`, `xpkSMPL_lib.s`, `functab_stub.s`,
`genfunctab.py`, `endmodule.s`, `Makefile`.

Host verification:
- 3000 pack iterations (random/dense/sparse, sizes 2..18k) -- all
  emitted streams byte-identical to an independent bit-exact model
- 887 full-coverage inputs round-trip cleanly; inputs covering all
  256 delta values always round-trip
- sparse histograms (<256 deltas used) produce the shipped
  desynchronized stream byte-for-byte (see findings/defects.md)
- error paths: inlen<2 -> -17, alloc failure -> -7, bad signature
  -> -26

See findings/defects.md for the substantial shipped quirks.
