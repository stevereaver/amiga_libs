# Codec

DUKE = NUKE 1.8 LZ core + byte-delta transform. The pack core
(code+0x302..0x710) and decode loop (0x888..0x90b) are byte-identical
to xpkNUKE_1.8_000_'s. DUKE's only codec-level additions:

## Delta preprocessor (code+0x182..0x1a4, common pack path)

```
a1 = xsp_InBuf;  d1.w = InLen-1          ; dbf-style count
a0 = work+92;    a4@(0) = a0             ; src -> delta buffer
d0.b = 0                                 ; running byte
loop:
  d2.b = *a1++ - d0.b                    ; d[i] = in[i] - in[i-1]
  *a0++ = d2.b
  d0.b += d2.b                           ; acc wraps mod 256
  dbf d1, loop
```

The whole NUKE cruncher then runs on the delta bytes: hash pairs,
matches and literals all reference the transformed stream. The
iteration count is `InLen.w` with pre-decremented DBF entry, so
**InLen==0 runs 65536 iterations** (reads past InBuf, writes 64KB
from work+92 into the tab1 area — cleared right afterwards anyway).

## Delta postprocessor (code+0x7f4..0x826, unpack tail)

```
d1.l = (xsp_OutLen + 7) >> 3             ; groups of 8
d1.w -= 1                                ; dbf entry
a1 = OutBuf; d0.b = 0
loop:                                    ; 8x unrolled
  d0.b += *a1; *a1++ = d0.b    × 8
  dbf d1, loop
d0 = 0; return
```

Out is integrated in place; the tail rounds **up** to an 8-byte
multiple and can write up to 7 bytes past OutLen (sic). For
OutLen==0 the loop runs 0x10000×8 bytes (never reached in practice —
a 0-outlen pack never produces a decodable stream). OutLen is read
from `xsp+16` *after* decode, i.e. the caller-supplied expected size.

## Stream format (shared with NUKE)

Four interleaved bit/byte streams plus a backward literal area,
written into one buffer in allocation order:

1. **flag** — 1 bit/token, MSB-first, 16-bit accums: `1` = match;
   `01` = single literal; `00` = counted literal run.
2. **2-bit** — 16-bit accums: literal-run count codes
   (`00`=+3&continue, `01`=+4, `10`=+3, `11`=+2) and the
   match-length extension for classes 10–15 (`v`→+v-… see below).
3. **nibble** — 32-bit accum, `rorl #4` chained via X: class code
   nibble, then long-length extension nibbles.
4. **xbits** — MSB-first, 16-bit granularity: offset residual bits.

Literals are stored **backward** from `outbuf+outbuflen-4` and are
appended after the streams, preceded by `0xfb` padding so the file
ends 4-aligned (pad condition: `(outcur + nlits) & 3 == 0`).

Each stream's **first flush writes to the scratch slot** at work+80
(a4+80 stored into ptr1..4), so the leading word/long of each
stream's staging is a discarded write, not file data.

Positions are 1-based: pair hash `src[p-1]<<8 | src[p]`, window
0x6a8f, chain tables tab1[pair]→newest pos / tab2[pos]→prev.
tab2 is lazily re-cleared via a moving frontier; the pos-0 chain
slot doubles as the search sentinel (`tab2[0]=d5`).

## Match classes (tables @0x712)

`seltab = {0,0,4,10}` by min(lencode,3) → base into the class walk:

```
classes 0-3   len≤1 maxoffs 0x10/0x40/0x100/0x200     4/6/8/9 bits
classes 4-9   len=2        0x10/0x80/0x200/0x800/0x2000/0x4000
classes 10-15 len≥3        0x20/0x80/0x200/0x800/0x2000/0x4000
```

copies: classes 0-3 → 2, classes 4-9 → 3, classes 10-15 → 3 plus a
2-bit extension (v=1→+3, v=2→+2, v=3→+1, v=0→+3 then nibble chain:
nibble 0 → +15 and another nibble; nibble n → +16-n total).

Match reject rule: len-code ≤1 (i.e. len 2–3) with offset ≥ 336
(0x150) is demoted to a literal.

## Return semantics

- pack core returns `outlen` (a1-dst) or -1 on literal/stream overlap.
- wrapper: `xsp_OutLen = d0`; `bmis → -17`; **`bls` → success when
  outlen ≤ inlen** (`6304` = BLS, *lower-or-same*, not BCS). A pack
  that produces exactly `inlen` bytes still returns 0 — observable
  with lit16 ('abcdefghijklmnop' → 16-byte stream).
- AllocMem failure → -7. Unpack always returns 0.
