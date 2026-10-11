# xpkSMPL.library 1.2 "SMPL"

Froehling XPK sublibrary: "Sample Huffman V1.2" (Jorma Oksanen,
1 Oct 2013) -- dynamic Huffman compression with delta precoding.
1,688-byte single-hunk library, code hunk content 0x620 bytes.
Successor of xpkSMPL 1.1 with reworked workmem layout and codec.

## Vectors
| LVO | Function |
|-----|----------|
| -6/-12/-18 | LibOpen / LibClose / LibExpunge |
| -24/-48 | null stub (reserved / PackReset no-op) |
| -30 | `XpksPackerInfo` -> static XpkInfo descriptor |
| -36 | `XpksPackChunk` -- Huffman encoder |
| -42/-60 | `XpksPackFree` -- frees xsp_Sub[0] workmem |
| -54 | `XpksUnpackChunk` -- trie/fast-table decoder |

Functab is the standard Froehling word-offset table: `-1` marker,
ten word offsets from the marker, `-1` terminator.  Null vectors
hold a negative offset reaching hunk+0 (`moveq #0,d0 / rts`).

## Layout
- `7000 4e75` entry stub, packed RomTag: AUTOINIT, ver 1
- InitTable dataSize 0x26; LibInit stores seglist at base+34
- datatab: ln_Type 9, name `xpkSMPL.library`, flags 6, ver 1 rev 2,
  idstring `xpkSMPL V1.2 (1 Oct 2013) by Jorma Oksanen`
- XpkInfo descriptor: single mode "dynamic" (upto 100, flags 1,
  pack mem 12808, unpack mem 4100, DefMode 100)

## Stream format
- BE16 signature `0x0001` (decoder rejects != 1 with -26)
- 256-entry code table: 4-bit length nibble per symbol (0=absent);
  nibble 15 escapes to `15 + nibble` (len 15..30); each present
  length is followed by the code itself (len<=16 raw, else
  len-16 bits then a 16-bit word)
- delta-coded samples, one Huffman code each, MSB-first
- trailing 32-bit pad long (decoder reads up to 2 bytes past end)

## Codec
- pack: delta histogram -> sorted-list Huffman merge (before-equals
  leaf insert) -> codes collected via roxr bit31 accumulate ->
  nibble length table + data codes -> pad long
- unpack: binary trie (4-byte nodes, word child offsets from a5)
  + 1024-entry 10-bit-prefix fast table built by walking the trie;
  fast path emits `(unconsumed<<8)|sym`, link entries = nodeoff-0x800
- See `structures/workmem.md`, `functions/index.md`,
  `algorithms/codec.md`, `findings/defects.md`.

## Verification
- host model (HOST_TEST): 23/23 round-trips, bad sig -> -26
- encoder output byte-exact vs independent Python model of the
  disassembly on all tested inputs
- descriptor block byte-identical modulo relocated offsets
