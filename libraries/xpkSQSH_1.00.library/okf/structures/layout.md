# xpkSQSH 1.00 — layouts

## Stream format

```
u16 inLen (big-endian) | u8 in[0] (first sample, raw) | bitstream
```

Bits are consumed MSB-first. Every byte after in[0] is `prev - delta`
(literal) or a copy (match). `litpress` is a saturating counter
(cap 31): +1 per literal token, -1/-2 per match len 3/4+, clamped at
0. `litpress <= 7` = normal mode, `> 7` = inverted mode — both sides
agree on the boundary (encoder `cmpaw #7,a5; bhi`, decoder
`cmpw #8,d1; bcc`).

### Normal mode

- `0` + 8-bit signed delta → one literal
- `1` + match token

### Inverted mode (litpress > 7)

- `1` → literal: wid = prevw if prevw < 8 else 8; run = 5 deltas if
  wid < 8, else 1 or 2 by the `mom` accumulator (`mom >= 20` -> run 2,
  adding mom += 8).
- `00` + match token (the packer clears the usual '1' marker bit and
  shifts the whole token left 2 — i.e. prefix '00').
- `010` → slot 2; `0110` → slot 3; `0111` → 3-bit field **read at the
  tested bit** (the field's top bit is the '1' already seen) →
  slot 4..7.
- `wid = widtab[prevw*8 + slot - 17]` — flat 56-byte table @0x7fa,
  one 8-byte row per prevw 2..8 (cols 1..6 hold the width remap, col 0
  and col 7 are 0/unused).

### Literal deltas

After the tag, `run` signed deltas of `wid` bits each;
`prev = (u8)(prev - dv)`. Tokens cover 1, 2 or 5 bytes.

### Literal-run selection (packer, litcost @0x4b0)

Scans **5** upcoming deltas (`dbf d7=4` → 5 iterations),
`dl<0 -> -dl-1` (`neg.b`+`subq.b #1`, i.e. ~dl), ORs into acc:

- `acc <= 1` → wid 2, run 5
- else wid = `33 - bfffo(acc{24:0})` = bitwidth(acc)+1; run 5, or
  run 2 when wid == 8
- `wid >= 7 && mom < 20` → wid 8, run 1 (escape hatch under pressure)

tag = flat grid @0x570 `tag[prevw*8 + w]` (u16 {bits,value}); w==8
wraps to the next row's col0, w==9 lands on a `0000` pad (defect #2).

### `mom` (accumulator in d0.hi alongside prevw in d0.lo)

`mom += 8` when a literal token has run >= 2; every token tail does
`mom -= mom >> 3`. Decoder mirrors it for the wid-8 run length.

### Match token

len prefix: `0`+e → 2+e; `10`+e → 4+e; `110`+e → 6+e; `1110`+3b →
8+x; `1111`+5b → 16+x (max 47).
dist class: `1`+12b → dist 0x101+fld; `01`+14b → dist 0x1101+fld;
`00`+8b → dist 1+fld.
`src = out - 1 - dist` (encoder emits dist-1 in fld). litpress -= 1
(len==3) or 2 (len>=4).

## Pack workmem (alloc 0x22080, freed every pack call)

| off | content |
|-----|---------|
| +0x0000 | u16 head[] — hash heads, hash = `(in[p]<<4)^in[p+1]` & 0xfff; table sized 0x2080 (4160 u16) though only 4096 hashes exist |
| +0x2070..0x207f | scratch longs (token/len/bitbud/inlen slots) — reuses the unused tail of the head table |
| +0x2080 | u16 node[pos][2] — two slots per position; child chosen by sign of first mismatched byte (`<=0` slot0, `>0` slot1) |

Insert order: on each token the packer inserts the NEXT `a2cnt`
positions (the previous token's len/run), skipping positions whose
hash equals the previous walked position's (`d3 == d5`) except the
last (`d4 == 0`) which always walks. The emitted token describes the
match found at the last inserted position. Winner rule:
`r <= best_rem && d2 > floor` (longest match, nearer candidate on
ties). `cmpm.b` compares up to 46 bytes — past `in+inlen` at the
tail (defect #3).

## XpkSubParams (a0)

| off | field |
|-----|-------|
| +0  | xsp_InBuf |
| +4  | xsp_InLen (only the low word is used) |
| +8  | xsp_OutBuf |
| +16 | xsp_OutLen (written by pack) |
| +52 | xsp_Sub[0] — workmem ptr (left stale after FreeMem) |
| +56 | saved libbase (restored on return — the wrapper trashes a6 with SysBase) |

## Library private data (dataSize 0xa8, built by LibInit)

| off | content |
|-----|-------|
| +0x26 | XpkInfo block — XpkInfoVersion=1, LibVersion=1, MasterVersion=1, ModesVersion=0, Name "SQSH", LongName "Squash 1.0", ID 'SQSH', Flags=0x2009, Max/Min/DefPkInChunk=0x8000/16/0x8000, 4 msg ptrs, DefMode=100, ModeDesc=lib+0x7e |
| +0x7e | XpkMode "normal" — Upto=100, Flags=1, PackMem=0x22080, UnpackMem=0, PackSpeed=25, UnpackSpeed=300, Ratio=424, ChunkSize=32 |

Return codes: pack 0 / -7 (AllocMem fail) / -17 (bit-budget
overflow); unpack always 0.
