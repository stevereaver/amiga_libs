# xpkSQSH 1.2 (020) — layouts

## Stream format

```
u16 inLen (big-endian) | u8 in[0] (first sample, raw) | bitstream
```

Bits are consumed MSB-first within each byte. All output bytes after
in[0] are produced by tokens; output byte *i* is always reconstructed
as `prev - delta` (literal) or copied (match), so `prev` is the
running previous output byte.

## Tokens

`litpress` is a saturating counter (cap 31): +1 per literal token,
-1/-2 per match of len 3/4+, 0 clamp. When `litpress <= 7` the stream
is in *normal* mode; `> 7` is *inverted* mode.

### Normal mode (litpress <= 7)

- `0` + 8-bit signed delta → one literal.
- `1` + match → match token.

### Inverted mode (litpress > 7)

- `1` → literal: width = prevw (last literal width; 8 first time);
  run = 5 deltas if wid < 8, else 1-2 (see acc rule).
- `00` + match → match token (marker bit inverted: the packer clears
  the marker and prepends an extra '0').
- `010` → width slot 1
- `0110` → width slot 2
- `0111` + 2-bit x → width slot 3+x
- then `wid = widtab[(prevw-2)*8 + slot]` (flat 56-byte table, slots
  0..6 map to widths 2..8 permuted by prevw).

### Literal deltas

After the token, `run+1` signed deltas of `wid` bits each:
`prev = (u8)(prev - delta)`. Emit side writes `(u8)(pv - nb)` —
byte-wrapping signed delta (`sub.b`). Literal tokens therefore cover
1, 2 or 5 output bytes.

### Literal run width selection (packer)

The packer scans the 5 upcoming deltas, zigzags them
(`dl<0 -> -dl-1`, i.e. `neg.b;subq.b #1`), ORs them into `acc`, and:

- `acc <= 1` → wid 2, run 5
- else `wid = bitwidth(acc)+1` (original uses `bfffo d1{24:7}` then
  `w = 33-offset`), run 5 — except wid 8 → run 2
- if wid >= 7 and the literal-pressure accumulator `d0h < 20` →
  wid 8, run 1 (escape to full-byte literals under pressure)

The literal token itself is `deltok[prevw-2][(w-2)*2]` — a 7-slot
prefix code {bits,value} permuted per previous width.

### acc (literal-pressure accumulator, d0h)

`acc += 8` per emitted literal token (when run >= 2), then every
token `acc -= acc>>3`. Decoder mirrors it to decide the wid-8 run
length: `run = acc >= 20` → 1 or 2 literals.

### Match token

`lentab[len]` (16-bit) carries marker '1' + length prefix + ext bits;
`lenextra[len]` is its bit length. Length tree:

- `0`+e → len 2+e (2-3)
- `10`+e → len 4+e (4-5)
- `110`+e → len 6+e (6-7)
- `1110`+3b → len 8+x (8-15)
- `1111`+5b → len 16+x (16-47)

Then the distance field (2-bit prefix):

- `00` + 8-bit fld → dist = fld (0..255)
- `01` + 14-bit fld → dist = 0x1100 + fld
- `1` + 12-bit fld → dist = 0x100 + fld

copy: `src = out - 1 - dist`. In inverted mode the whole token is
prefixed with '00' and the marker '1' is cleared.

## Pack workmem (alloc 0x22080)

| off | content |
|-----|---------|
| +0x0000 | u16 head[0x1000] — hash-chain heads, hash = (b0<<4)^b1 |
| +0x2080 | u16 node[0x8000][2] — dual-slot chain links per position; slot = (matchlen>0) — a binary "match vs mismatch" threaded tree |

Match find: walk `head[h]` then `node[d2][full?]`; candidate compare
is `cmpm.b` up to 46 bytes past the end (reads past in+inlen).
Winner rule: `r <= best_rem && d2 > floor` — keeps the longest match
and prefers later (closer) candidates on ties. `floor`/`rem` reset
per *walked* position but carry across hash-equal (`d3 == d5`)
positions — a deliberate "same hash → same chain" shortcut.

## XpkSubParams (as used)

| off | field |
|-----|-------|
| +0  | xsp_InBuf |
| +4  | xsp_InLen |
| +8  | xsp_OutBuf |
| +16 | xsp_OutLen (written by pack) |
| +52 | xsp_Sub[0] — workmem pointer (NULL -> pack allocs it) |

## Descriptor (verified byte-exact, hunk @0x660)

xpkinfo head `0001 0001 0002 0000`; name "Squash", longname
"Squash 020+ V1.2", desc "LZ based cruncher, special algorithms for
8 bit sound data, fast decrunching", id 'SQSH', flags 9,
chunk 0x8000/0/0x8000, msgs Squashing/UnSquashing/Squashed/UnSquashed,
DefMode=100.
Mode "normal": Upto=100, PackMem=0x2080, UnpackMem=0, PackSpeed=0x0f,
UnpackSpeed=0xe9, Ratio=0x1a8, ChunkSize=0.
