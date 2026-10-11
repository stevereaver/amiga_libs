# xpkSLZ3.library 1.1 "SpeedLZ"

Froehling XPK sublibrary: "Speed Lempel-Ziv77 for graphics data and
fast decompress" (id string `xpkSLZ3 1.1 (25.08.11)`).  Descriptor
credits "Based upon a workshop of Adisak Pochanayon 1993, all rights
reserved".  1,532-byte single-hunk library.

## Vectors
| LVO | Function |
|-----|----------|
| -6/-12/-18 | LibOpen / LibClose / LibExpunge |
| -24/-42/-48/-60 | null `moveq #0,d0/rts` |
| -30 | `XpksPackerInfo` -> static XpkInfo descriptor |
| -36 | `XpksPackChunk` -- LZ77 encoder (256 KB context table) |
| -54 | `XpksUnpackChunk` -- flag-grouped stream decoder |

## Layout
- `70ff 4e75` entry stub, packed RomTag: AUTOINIT, ver 1, NT_LIBRARY;
  matchtag/endskip/name/idstr/init are all RELOCATED (RELRELOC32 x18)
- InitTable dataSize 0x26; LibInit stores the seglist at base+38 --
  one long past the 38-byte PosSize, legal only because AllocMem
  rounds the allocation to 40 bytes (see findings/defects.md)
- datatab: ln_Type 9, name, flags 6, ver 1, rev 1, idstring
- word-offset functab: -1 marker, 10 word offsets, -1

## Stream format
- one flag byte per group of 8 items, MSB first
- flag byte 0x00: next 8 bytes are literals (decoder fast path:
  copies two longs verbatim)
- bit 1 -> 2-byte match token `((off>>4)&0xf0)|(len-2)`, `off&0xff`
  (12-bit backward offset, length 3..17)
- bit 0 -> literal byte
- a zero token byte terminates; the packer forces the next flag bit
  high so the decoder always takes the token path to read it, or
  emits an 0xff flag + 0x00 token after a full group

## Packer
- AllocMem(0x40002, MEMF_PUBLIC) per call, freed on exit (the XpkMode
  descriptor still claims 1 KB pack memory -- verbatim defect)
- context = (src[i]&63)<<6 | (src[i+1]&63); 4096 contexts x 16-deep
  position LRU, table filled with -1
- packing starts at position 1: output slot 1 is pre-seeded with
  src[0] and the flag counter starts at 1 so the seeded literal
  occupies flag bit 7
- tries the 16 LRU candidates; if none reaches length 17 it then
  scans EVERY older position down to pos-4095 (the brute-force
  phase is only reachable when all 16 candidates were in-window)
- best length clamped to (srclen-1)-pos; len>2 emits a match token,
  otherwise a literal
- context LRU updated once per consumed input byte

## Decoder
- reads xsp[0]=src, xsp[8]=dst; decompresses until the zero token;
  does NOT write xsp_OutLen (returns d0=0 only)

## Source
`source/xpkSLZ3.c`, `xpkSLZ3_lib.s`, `functab_stub.s`,
`genfunctab.py`, `endmodule.s`, `Makefile`.
Host differential: 2000 pack->unpack round-trips over random,
low-entropy, run-length and sparse inputs -- 0 failures.
