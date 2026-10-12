# xpkFAST packers

Both packers share the emit machinery: `pend` = how many
positions to insert into the hash table(s) before the next
evaluation (1 after a literal, `len` after a match).  Each
iteration hashes `pend` positions forward from the pre-incremented
cursor and evaluates the last.  Positions at/near the input end
get hashed with out-of-bounds reads (the original reads past
`inbuf+inlen`).

## Speedy (mode < 79)

- Workmem 0x10004: one 16384-entry ULONG table at alloc+4
  (the `size` long sits at alloc+0).
- Hash: `h = b0; h = (h<<3 + b1)<<3 + b2` where the `+bN` is an
  `add.b` — wraps only the low byte.  Range 0..16383.
- Insert: `cand = tab[h]; tab[h] = src` — single candidate,
  greedy.
- Reject if `src - cand > 0xfff` (signed compare — a stale
  candidate pointer ahead of `src` produces a negative offset
  that *passes* the test; see defects).
- Full 18-byte compare; len < 3 → literal, else match.
- len 3..18 reachable; the compare chain is fully unrolled with
  per-length `moveq #len,d5; addi.b #(18-len),d0` exits.

## Crawling (mode >= 79)

- Workmem 0x44004: 65536-entry ULONG hash table at alloc+4
  (reached via `a5 = alloc+0x40000` plus the *negative*
  hash index `0xfffc0000|h16<<2`, which cancels the +0x40000),
  plus a 4096-entry ULONG chain table at alloc+0x40000.
- Hash: `h16 = (b0<<8)|b1`, then `add.b b2` — low byte wraps.
  (The `moveq #-1` seed keeps the high word at 0xffff through
  `lsl.w #8`, producing the negative index.)
- Insert: `cand = htab[h]; htab[h] = src;
  chain[src&0xfff] = cand` — chain indexed by the *pointer's*
  low 12 bits.
- Chase the chain: for each `cand`, break when
  `src - cand > 0xfff`; quick-reject on `src[best]` vs
  `cand[best]`; on pass, compare bytes 1..17 (byte0 trusted via
  the hash) with a 17-instruction `cmpm` chain; `len` =
  compares executed, clamped to `left`; update `best`/`off` when
  `len > best`; early-out `best >= 18` is dead code.
- `next = chain[cand & 0xfff]`; a zeroed chain entry yields
  `cand=NULL` → `off` huge → loop exits.
- Because `len` counts executed compares, a full 17-compare run
  yields len = 17 even though 18 bytes matched: **the crawler
  can never emit len = 18** (token nibble never 0).
- `best` rides `d5` as `(off<<16)|len` — `ext.l` recovers len
  for `pend`, `swap/asl#4` builds the token.

## Emit

- Literal: byte → data cursor, `bits <<= 1`, `pend = 1`.
- Match: `*--cw = (off<<4)|(18-len)`, `bits = (bits<<1)|1`,
  `pend = len`.
- On `bits & 0x10000`: store word at `slot`, `slot = --cw`,
  `bits = 1` — so each stored ctrl word sits *above* the tokens
  of the items it describes (the previous `slot = --cw`
  reserved that space).
- `left -= pend`; loop ends when `left <= 0` → `pk_tail`.
