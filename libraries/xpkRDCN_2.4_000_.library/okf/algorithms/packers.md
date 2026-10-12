# xpkRDCN 2.4 — Packers

Both packers emit the same token set (see format.md): literal,
RLE2B, RLE3B, MATCH2B, MATCH3B under 16-item BE control words.

## Speedy packer (orig 0x1e4, mode <= 79)

Greedy single-candidate hash packer.

- `a1=in cur, a3=in+inlen, a0=out (ctrl slot), a2=out+2 (data cur)`.
- `d6 = out - 48 + OutBufLen` — overflow limit checked once per
  ctrl-word boundary (`a2 > d6 -> -17`); the -48 margin covers the
  worst-case mid-group burst.
- Refuses `inlen <= 0x12` with -17.
- Item order: RLE check first (two unconditional `cmp.b` reads —
  may read up to 2 bytes past the end of short tails), then LZ.
- RLE: run cap 0x1012. Emits len-3 byte for len<=18, else
  `[0x10|(len-19)&0xf][(len-19)>>4][byte]`.
- Hash (4096-long table at Sub[0]):
  ```
  h = ((b0&0xf)<<8 | b1) ^ (((BYTE)b0 >> 4) | (b2<<4))   & 0xfff
  ```
  The `asr.b` on b0 sign-fills the low byte's high nibble for
  b0>=0x80, which ORs b2's low nibble away — a faithful quirk that
  degrades hash quality for high bytes.
- Match: single candidate from the slot; window `dist <= 0x1002`
  (SGT check — dist 1..2 also pass! see defects). Compare loop
  `cmpm` stops on mismatch, source==cur overlap, or input end;
  len cap 0x10f; len <= 2 falls back to literal.
- Both loops end with an unconditional `subq.w #1,a1` — including
  the overlap/count exits, so a max-length match overlaps the next
  item by one byte (reprocessed, harmless redundancy) — faithful.
- Emit: len<=15 `[len<<4|enc&0xf][enc>>4]`; else
  `[0x20|enc&0xf][enc>>4][len-16]` where enc = dist-3.
- Finish: always writes the pending ctrl word; if input ended
  exactly on a group boundary this emits a phantom 0x0000 word
  (harmless: decoder's end-check discards it).

## Crawling packer (orig 0x22a, mode >= 80)

Hash-chain packer with lazy position insertion.

- `a2=in-1 cur, a6=out+2 data cur, a3=out ctrl slot, a5=wmem hash,
  a4=wmem+0x40000 chain, d7=remaining`.
- Overflow limit = `out + InLen` — output must be strictly smaller
  than input; checked per item (`a6 >= lim -> -17`). Hence inputs
  <= ~4 bytes or incompressible data always fail.
- Per item: `dbf d5` inserts prevLen positions into the hash —
  position a2+1..a2+prevLen each get `htab[h]=pos`,
  `chain[pos&0x1fff]=old head`. The eval position is the last
  inserted (= new item start); its own insert makes the hash head
  point at itself, but the eval's `d0` was captured as the OLD head
  = real predecessor.
- Hash: `h = (b0<<8) | ((b1+b2)&0xff)` (add.b wraps), 64K-long tab.
- Chain walk: `dist = a2-cand`; reject `dist >= 0x1003`, skip link
  `dist < 3` (so dist 1..2 NEVER emitted here, unlike speedy).
  Skip-chain trick: only full-compares candidates whose byte at
  offset `best` equals `a2[best]`. First `best` bytes must all
  match, then extend to `maxlen = min(0x10f, remaining)`. best/dist
  packed in one register (swap) — `move.l d2,d5` keeps dist in the
  high word, len in the low.
- RLE after the chain: run len capped `min(0x1012, remaining)`;
  **RLE wins ties** (`rle >= best` prefers RLE).
- Literal: 1 byte, `d5=1`; ctrl bit clear.
- Tail: `d7 -= len` per item; on `d7 <= 0`, if bit index is back at
  15 (full boundary) rewinds the fresh empty ctrl slot (`a6 -= 2`),
  else writes the partial ctrl word.
- Tail bytes (d7 < 3 at loop top): `a2 += prevLen` then forced
  literals, one per byte. Degenerate inputs (0-2 bytes) emit a
  single literal each — and then hit the out>=in limit anyway.

## Shared emitter notes

- ctrl words are written big-endian into the reserved slot behind
  the data cursor.
- speedy checks overflow only at 16-item boundaries (48B margin);
  crawler checks per item against out+inlen.
