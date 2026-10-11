# algorithms

## Pack (hunk 0x208 wrapper -> core at 0x218 region)

1. `d = (src[i] - src[i-1]) & 0xff` delta histogram, word counts.
   The `inlen` long is used with WORD semantics throughout (see
   defects 4).
2. Sorted leaf list: iterate sym 255..0, insert nonzero-hist
   entries into a descending-freq singly-linked list (head node at
   wk+0x10), stable after equals.  Arena nodes at wk+0x28, 24 bytes.
3. Sentinel: `st a4@(6)` gives the slot after the last leaf
   sym=0xffXX; internal nodes reuse the slot and never overwrite
   the field, so the codegen's `sym>=0x8000` stop works.
4. Merge: take list[0]+list[1], set edges 0x4000/0x8000, parent
   both to a fresh internal node, reinsert by freq (front if
   smaller than list[0], else after the last <= freq).  Single
   remaining node gets fake-parented to the sentinel.
5. Codegen: for each leaf walk parents; per step `addw d0,d0`
   (edge<<1 -> X) then `roxrl #1,d2` -- the leaf's own edge becomes
   the code's LSB, the root edge the MSB.  `lentab[sym]` =
   32-remaining, `codetab[sym]` = right-justified code.
6. Emit: BE16(1); for sym 0..255: len 0 -> `subq.b #4` + wipe
   (defect 1); len<15 -> 4-bit len; len>=15 -> 8-bit `(len-31)&0xff`;
   then the code via shared emit (len>=16 splits into two <=16
   parts).  Then per delta the code via shared emit, then a 4-byte
   pad long.
7. Bit writer: 32-bit accumulator, `code << space` fills MSB-first;
   when a byte-borrow occurs on `space -= len` it `rol16`s, stores
   the low word, `space += 16`, `clrw` the stored half.

## Unpack (hunk 0x676 wrapper -> core at 0x46a)

1. BE16 sig == 1 else -26.  Window reader: 32-bit d7, `left` counts
   remaining bits below the consumed top; refill = `rol16` +
   `movew` (REPLACES low word -- consumed bits park in high).
2. Per sym 0..255: 4-bit nibble len (0 skip; 15 -> +ext nibble
   giving 15..30); code read (len>=16 as two parts), MSB-justified,
   walked bit-by-bit into a binary trie at wk+0 (4B nodes, links
   are U16 offsets), leaf = `0xffffff00|sym`.
3. Root fixup: if root's bit-1 field is empty copy the bit-0 link.
4. 1024-entry fast table: for each 10-bit prefix index, walk the
   trie shifting the index MSB-first; leaf -> `steps<<8|sym`;
   exhausted -> `link-0x800` (negative).
5. Decode: fetch 10 bits, fast-table lookup; positive -> acc+=sym,
   give back `steps` bits; negative -> consume 1 more bit and walk
   the trie via `btst`/`rol` until a leaf.  Output = accumulated
   delta byte.  Count = `1 + (UWORD)(outlen-1)` (defect 7).

## Public wrappers

- `XpksPackChunk`(-36): AllocVec(0x3800, CLEAR|PUBLIC) into
  xsp_Sub[0] if unset (failure -> -7), then the pack body.
- `XpksUnpackChunk`(-54): same workmem acquisition, then the decode
  body.
- `XpksPackFree`(-42/-60): FreeVec(xsp_Sub[0]), clears the slot.
- -30 returns the static descriptor; -24/-48 are LibNull (PackReset
  slot is inert).
