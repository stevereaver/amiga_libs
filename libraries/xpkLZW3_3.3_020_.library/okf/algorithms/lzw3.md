# xpkLZW3 -- "LZ-Welsh" greedy LZ77

Same family as xpkSLZ3/FastLZ, scaled up for 68020+:

    hash      = w(p) ^ w(p+2)               (4-byte window)
    tables    = hash[65536] + chain[65536]  (pointer values)
    window    = dist <= 0xffff              (64 KB)
    match len = 4..259                      (maxlen = min(259, rem))

    stream = [flaglong][32 items]...[flaglong][items][0x0000]
    flaglong = big-endian, bit i = item i, 1=match 0=literal
               all-zero group = 32 literals (8-long fast copy)
    literal  = 1 byte
    match    = [-dist:u16][len-4:u8]
    end      = match flag bit + 0x0000 token word

The encoder packs [dist:len] into one register via `swap`,
which is why the emit is `swap; negw` -> -dist, and why
`extl` after emit recovers len for the advance.

Chain walk is newest->oldest via chain[pos & 0xffff];
`len >= best` accept means the LAST (farthest) candidate
wins ties.  Early exit when best reaches maxlen.

Decoder flag mechanism: the token word reloads into a
register whose high word stays 0xffff, giving free sign
extension -- the stored word is literally -dist.

## Notable

- Requires 68020+: the flag long is `movel`-stored at
  word-aligned slots (group of 32 items = 32+2m bytes, m =
  match count -> +2 mod 4 possible) and match tokens are
  `movew`-written at arbitrary parity; both fault on 68000.
- 512KB workmem -- the "020+" budget, vs xpkSLZ3's 278KB.
