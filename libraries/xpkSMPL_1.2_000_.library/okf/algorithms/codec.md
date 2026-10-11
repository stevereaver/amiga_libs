# xpkSMPL 1.2 codec details

## Delta precoding
Each input byte `c[i]` is coded as `d[i] = (c[i] - c[i-1]) & 0xff`
with `c[-1] = 0`.  The decoder accumulates `acc += sym`.

## Bit writers/readers
Packer emit (n<=16 per call): `space -= n; if space<0 { if
(--budget<0) bail -17; out += acc>>16; acc <<= 16; space += 16 }
acc |= v << space`.  Codes >16 bits split `n-16` + `16`.
Final flush is a raw `wr32` of the accumulator (pad bits zero).

Unpacker reader: window `win` with `bits` pending low bits;
`bits -= n; if bits<0 { win = win<<16 | rd16(in); in += 2;
bits += 16 } return win >> bits` -- the return is UNMASKED
(stale consumed bits ride above the n low bits); callers mask or
left-justify to discard them.  `getcode(n)` for n>16 reads `n-16`
bits then a 16-bit word.

## Code collection (pack)
Leaves hold markers from the merge: 0x4000 = left child, 0x8000 =
right child, root mark = 0.  Walking leaf->root, each marker's
bit15 is roxr'd into bit31 of `c`; after k levels `c >>= (32-k)`
right-justifies so the root-side bit is the code MSB.  Emitted
MSB-first the code reads root-down -- standard Huffman.

## Length-table entry format (pack)
per sym 0..255: len==0 -> single 0 nibble; len<15 -> nibble len;
len 15..30 -> nibble 15 then nibble (len-15); then the len code
bits.  Lens >=31 cannot be represented (see defects).

## Trie insert (unpack)
code is left-justified in d2 (`code << (32-len)`); per bit
`add.l d2,d2` takes bit31: 1 -> `a1+2` (right), 0 -> `a1+0`
(left); missing children get `arenapos` (advances by 4, node
zeroed); after len steps the node long becomes `0xFFFFFF00+sym`.

## Fast table (unpack)
For each of 1024 prefixes (idx<<6 in a word walked MSB-first):
at most 10 trie steps; hitting a leaf at step k stores byte pair
`(10-k)<<8 | sym`; exhausting 10 bits stores `d4 - 0x800` where
d4 is the last selected child word (a node offset) -- a negative
link back into the trie.  Decode probes `dectab[(win>>bits)&0x3ff]`;
positive entries emit the low byte and give back `hi` bits
(`bits += hi`), negative entries resume the walk at
`*(ULONG*)(base + 2048 + link)` = the node at `link+0x800`.
