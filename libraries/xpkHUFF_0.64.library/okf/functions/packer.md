# xpkHUFF 0.64 — packer (XpksPackChunk, LVO -36)

Signature: `XpksPackChunk(struct XpkSubParams *xsp /*a0*/,
                         struct HuffBase *b /*a6*/) -> LONG`

Work allocation: `AllocMem(0x7324=29476, MEMF_ANY|MEMF_CLEAR)`.
Failure -> -7.

## Algorithm

1. Copy xsp fields into a shadow block at workmem+520
   (+520 inbuf, +524 inlen, +528 outbuf, +532 outlen(out),
   +536 xsp+12, +540 outlen copy).
2. **Histogram**: `d0 = inlen-1` then a `dbf` loop —
   `hist[sym]++` over in[] into a u16[256] at +8.
   **WORD-BOUND**: only `(inlen-1)&0xffff)+1` bytes counted.
   Counts are u16 (wrap at 64k).
3. **Leaf records**: contiguous `HuffN` nodes at +544 for each
   used symbol (flag=4). Next slot's flag stays 0 = terminator.
4. **Sorted list**: rescans the leaf array for the max-count
   unlinked leaf (`bhi` = strictly-greater keeps the LAST
   equal-count leaf) and prepends to `head`. Produces an
   ascending-frequency list, byte-ordered among equals.
5. **Merge**: pop the two lowest nodes, link under a new
   internal node (flag=1) at +8768, reinsert sorted. Single-
   symbol inputs get a pseudo internal root. Root flag=5,
   traversal mark=-1.
6. **Serialize table** into workmem records at +21028:
   33 bytes per symbol {len, code bytes, pad}. Walks the tree
   twice (down-left mark propagation), emits MSB-first code
   bytes; also fills the +16932 pointer array (sym -> record).
7. **Budget gate**: `xsp+12 <= 6` -> error (see codes).
8. **Header**: `u16 0` + `u32 hash` (0xABADCAFE when pw==NULL,
   else pwhash()).
9. **Table emit**: per symbol `0xff` if absent else `len-1`
   followed by `(len>>3)+1` code bytes (len field is len-1,
   so on the wire code bytes = ((len-1)>>3)+1).
10. **Bit emit**: for each input symbol (**same `dbf` word
    counter on `inlen-1`**), walk its code record MSB-first,
    `addx` bits into `d6`; every 8 bits flush a byte to
    `*a1++`, then `cmpa.l a4,a1; bcc fail` — budget is
    `a4 = outbuf + inlen`. Final partial byte is left-shifted
    to align and flushed (skipped when d4==7).
11. `xsp_OutLen = a1-outbuf` (also workmem+532/+540).
12. **Scramble** (pw != NULL): for out[6..outLen),
    `c = (plain ^ pw[i%len]) + prev_cipher`, seeded with
    `prev = pw[0]`. Loop is `subq.w #7` + `dbf` on OutLen —
    word-bound.

## Error returns

| code | condition                                            |
|------|------------------------------------------------------|
| -7   | AllocMem failed                                      |
| -10  | budget/pad overflow when xsp_Password != NULL        |
| -17  | budget/pad overflow (or xsp+12<=6) with NULL pw      |

Note the budget is `outbuf+inlen` — streams larger than the
raw input fail. The ~262-byte table overhead means small or
weakly-compressible inputs always fail; typical successful
inputs are large and skewed.

## >64k quirk (verified byte-identical)

`inlen=65537` packs **one** symbol (outlen 264):
`(inlen-1)&0xffff == 0` -> single dbf iteration. 80000 bytes
pack 14464. The resulting short stream is emitted normally —
the unpacker then runs wild (see unpacker notes).
