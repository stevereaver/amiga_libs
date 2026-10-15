# Codec

DUKE 1.6 = NUKE LZ core + byte-delta transform — the same stream
format as xpkNUKE / DUKE 1.8(000), but a different driver/memory
model: the delta pass writes to a separate 0x8000-byte scratch
(xsp_Sub[1]) instead of a work+92 in-arena buffer, and the decode
targets the scratch too (integration copies scratch → OutBuf).

## Delta preprocessor (code+0x848, called by PackChunk)

```
delta_encode(dst=xsp_Sub[1], src=xsp_InBuf, len=xsp_InLen)
                                          ; stack args, (dst,src,len)

d6/d5.b = 0                               ; two "prev byte" regs
if len <= 0: return                       ; tstl/ble — NO overrun
                                          ; for len==0 (unlike 1.8)
dead check: d0 = len & 7; cmpil #8,d0; bcc done
            — can never fire (len&7 < 8 always); preserved quirk
dispatch: jmp into unrolled block via word table
            table[r] enters the last r of 8 unrolled steps
loop body (8 output bytes per iteration, alternating d5/d6):
    out = in[i] - prev;  prev = in[i]     ; plain mod-256 delta
    len -= 8; bgt loop
```

Duff-device order: the **remainder** (len&7) is processed *first*
(via the dispatch jump), then full 8-byte groups. Exactly len bytes
written — no tail overrun.

## Delta postprocessor (code+0x91e, called by UnpackChunk)

```
integrate(dst=xsp_OutBuf, src=xsp_Sub[1], len=xsp_OutLen)

same Duff shape (dead cmpil #8 included):
    d6.b += src[i];  dst[i] = d6.b        ; cumulative sum mod 256
    exactly len bytes — again no overrun
```

Note: the decoder writes into Sub[1] and the integrate pass copies
to OutBuf, so xsp_OutLen bytes land in OutBuf exactly — unlike 1.8's
in-place 8-grouped version that can touch up to 7 bytes past OutLen.

## Stream format (identical to NUKE / DUKE 1.8)

Four interleaved bit/byte streams plus a backward literal area,
written into one buffer in allocation order:

1. **flag** — 1 bit/token, MSB-first, 16-bit accums: `1` = match;
   `01` = single literal; `00` = counted literal run.
2. **2-bit** — 16-bit accums: literal-run count codes
   (`00`=+3&continue, `01`=+4, `10`=+3, `11`=+2) and the
   match-length extension for classes 10–15.
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
0x6a8f (written `movew #0x6a90; subqw #1`), chain tables
tab1[pair]→newest pos / tab2[pos]→prev. tab2 is lazily re-cleared
via a moving frontier (4 bytes/iteration up to 2*(d5-window));
the pos-0 chain slot doubles as the search sentinel (`tab2[0]=d5`).

Decoder tables live at code+0x1a0 (nbtab), +0x1c0 (basetab),
+0x1e0 (copytab); encoder tables at 0x138 (seltab), 0x140
(thresholds), 0x160 (nbtab), 0x180 (codetab).

## Match classes

`seltab = {0,0,4,10}` by min(lencode,3) → base into the class walk:

```
classes 0-3   len≤1 maxoffs 0x10/0x40/0x100/0x200     4/6/8/9 bits
classes 4-9   len=2        0x10/0x80/0x200/0x800/0x2000/0x4000
classes 10-15 len≥3        0x20/0x80/0x200/0x800/0x2000/0x4000
```

copies: classes 0-3 → 2, classes 4-9 → 3, classes 10-15 → 3 plus a
2-bit extension (v=1→+3, v=2→+2, v=3→+1, v=0→+3 then nibble chain:
nibble 0 → +15 and another nibble; nibble n → +16-n total).
The decoder implements both extensions by jumping *into* unrolled
`moveb` copy runs (pc-relative indexed jmp, offset tables inline).

Match reject rule: len-code ≤1 (i.e. len 2–3) with offset ≥ 336
(0x150) is demoted to a literal.

## Return semantics

- pack core (0x2fa) returns `outlen` (outcur-dst) or -1 on
  literal/stream overlap.
- driver: `xsp_OutLen = d0`; `bmi → -17`; **`bls` → success when
  outlen ≤ inlen** (`6304` = BLS, *lower-or-same*). A pack that
  produces exactly `inlen` bytes still returns 0 — observable with
  lit16 ('abcdefghijklmnop' → 16-byte stream, rc=0).
- The error path falls through `moveq #-17,d0` then a **dead**
  `cmpiw #0x7000,d0`; the success branch targets the cmpi's
  immediate field `0x7000` which executes there as `moveq #0,d0`
  (branch-into-immediate constant sharing — see quirks).
- AllocMem failure → -7. Unpack always returns 0.
