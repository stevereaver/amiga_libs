# xpkBLZW 3.4 — Packer (orig 0x166)

## Setup

```
bits   = min(mode*7/100 + 9, 15)        ; muluw/divuw semantics
tabn   = tabsz[bits-9]                  ; {641,1283,2579,5147,
                                          10243,20483,40961}
alloc  = tabn*6 via workalloc()
out region out[0 .. inlen&~31) pre-cleared; writer at out+4;
limit = out + (inlen&~31) - 8  (the emit bound)
```

## Hash

`h = ((c << (bits-8)) ^ prefix) * 6` — a *byte* offset into the
6-byte entry table, unmasked: `c<<shift` ≤ 2^(bits-8)*255 and
prefix < 2^bits, so h < 2^bits*6 < tabn*6 always — the prime-ish
table sizes just over 2^bits make masking unnecessary.

Probe: first h, then step = h - tabbytes + 6 (negative), `h += step`
wrapping `if (h<0) h += tabbytes`.

Empty slot = `char` word -1 (init once per chunk/CLEAR by a
`move.w #-1,(a3)+ / addq #6` sweep).

## Insert (orig 0x28c)

```
if (depth > maxdepth) maxdepth = depth    ; (>=, unsigned)
entry.code = next
if (next < 0)  -> overflow path           ; next is signed!
entry.pfx = prefix; entry.chr = c
next++
if (next >= thresh):
    if (width == maxw):   -> checkpoint init
    elif (prefix >= thresh): emit 258; width++; thresh <<= 1
emit prefix; prefix = c; depth = 4
```

depth tracks consecutive match-hit extensions; max recorded is
written (rounded down to 4) as the stream's maxlen field.

## Checkpoint init (once, when width reaches maxw)

```
out[0..1] = maxw        ; header width field written here
next = -1               ; every later insert overflows
chk_in = in; chk_out = a1; chk_ratio = 0
```

## Overflow / ratio check (orig 0x318)

While `next < 0` every insert stores `entry.code = next` only (the
slot stays "empty" since chr/pfx are never written — harmless
garbage) and `subq.b` decrements next's low byte; every 256th
failed insert evaluates:

```
ratio = ((in - chk_in) << 8) / (a1 - chk_out)   ; divuw
if (ratio >= chk_ratio): chk_in=in; chk_out=a1; chk_ratio=ratio
elif (inlen-remaining < 127): skip
else: emit prefix; emit char; emit 257; goto reinit-hash
```

## CLEAR restart (orig 0x210)

Emits `[prefix, char, 257]` then re-inits: hash to -1, next=259,
width=9, thresh=512, reads a fresh first byte. maxdepth, the
out+0/2 header fields and the checkpoint state persist.

## Emit machinery

```
inline emit (prefix codes):  cursor bound = sp@(4) = limit
bsr    emit (256/257/258):   cursor bound = sp@(8) = chk_in
```

Both do `bitcur -= width; if (bitcur<0) {a1+=2; check; bitcur+=16}
*(ULONG*)a1 |= code<<bitcur`. Violation → -17.

## Flush

```
if (prefix >= thresh): emit 258; width++
emit prefix; emit 256; a1 += 4
out[2..3] = maxdepth & ~3
if (out[0..1] == 0): out[0..1] = width
xsp_OutLen = a1 - out
return 0
```

## Errors

`-7` workalloc failure, `-17` output budget exceeded
(incompressible input → XPK stores the chunk raw).
