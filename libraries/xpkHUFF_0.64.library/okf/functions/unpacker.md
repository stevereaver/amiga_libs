# xpkHUFF 0.64 — unpacker (XpksUnpackChunk, LVO -54)

Signature: `XpksUnpackChunk(xsp /*a0*/, base /*a6*/) -> LONG`

Work allocation: `AllocMem(0x1141a=70682, MEMF_ANY|MEMF_CLEAR)`.
Failure -> -7.

## Flow

1. Shadow fields: +8 magic u16, +10 hash u32, +14 data start,
   +18 bit-stream start, +22 outbuf, +26 inlen-6, +30 expected
   (xsp+16), +34 trie root.
2. `magic != 0` -> -26.
3. If `xsp_Password != NULL`: `pwhash(pw)` must equal header
   hash else -32. Then descramble in[6..inlen) into the buffer
   at workmem+5148 (`c = (cipher - prev) ^ pw[i%len]`,
   `prev = cipher`); loop counter `inlen-7` is `subq.w`+`dbf`
   word-bound.
4. **Trie build** over the 256-entry table (from data start):
   `0xff` = absent; else byte = `len-1`, then `((len-1)>>3)+1`
   MSB-first code bytes. Nodes at workmem+38, 10 bytes each:
   `{mark B, sym B, left L, right L}` — mark 0 internal,
   0xff leaf. Root at +38 (mark 0), `next` bump-allocated.
   The arena has 510 slots + root; a full 256-leaf tree needs
   512 nodes and overflows 10 bytes into the descramble
   buffer (live only on password streams — see defects).
5. **Decode — first loop**: `d0 = (dataend - streamstart) - 2`
   then `dbf d0` per INPUT BYTE (word counter — wraps at 64k).
   Each byte feeds 8 bits MSB-first into the trie walk
   (`add.b` carry = bit; carry set -> right@6, clear -> left@2).
   `move.w (a2),d3; bpl` continues; negative word = leaf ->
   `move.b d3,(a1)+` emits the symbol byte, `a2 = root`.
6. **Decode — tail**: `d0 = expected - produced` (long test for
   zero), then `dbf d0` — **decremented only after an emit**.
   The bit walk inside is unbounded (`bpl` loops straight back
   to the bit-reload head), so the tail emits exactly
   `expected - produced` more symbols no matter how many bits
   or input bytes that takes — reading `a0` past the input
   end and writing `a1` past outbuf+expected with no bounds.
   A negative count wraps the word to ~64k emits of garbage.
7. FreeMem, return 0.

## Error returns

| code | condition                              |
|------|----------------------------------------|
| -7   | AllocMem failed                        |
| -26  | header magic != 0                      |
| -32  | password hash mismatch                 |

## Verified edge behaviour

- expected < produced: tail counter wraps (word) -> ~65k
  garbage emits past the buffer — reproduced byte-identically.
- truncated streams: first loop reads stale memory past the
  input — identical bytes because the emulator memory image
  matches; on real hardware this is UB.
- inlen=65537 stream (1 symbol): wild walk descends through
  unmapped memory/library internals; exact garbage is
  code-dependent and not deterministically reproducible.
