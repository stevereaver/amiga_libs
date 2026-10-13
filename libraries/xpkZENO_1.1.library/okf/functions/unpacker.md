# xpkZENO 1.1 — unpacker (XpksUnpackChunk, 0x61a)

## Init (Sub[0]==0)

```
hash = in[0..4]
if hash != 0:
    hv = pwhash(xsp_Password)
    if hv != hash: return -32
Sub[1] = hv
bits = in[4], signed-clamped to 12..14
xsp+67 = bits; Tsize = 1<<bits; Sub[2] = Tsize
alloc = AllocMem(4*Tsize+8, MEMF_CLEAR); Sub[0] = alloc
alloc[0..4] = hv                        # dead store
Sub[1] = 0; Sub[1] = alloc + 4 + 2*Tsize  # T_char base
if alloc == 0: call UnpackFree (no-op, Sub[0]==0); return -7
T_char[255..0] = 255..0                 # identity, descending
```

The password is checked only on the FIRST call of a session —
repeat calls skip init entirely (and thus the check).

## Stream/data alignment

```
data = in + 6 + namelen
a2   = data & ~3        # aligned long base
off  = data & 3
d6   = 3 - off          # signed byte counter
if d6 != 0:             # off 0..2
    d6 = (3-off)*8 - 1
    code = (a2@ >> d6) & 0x1ff
    d6 -= 9
else:                   # off == 3 — BUGGY path
    code = (a2@+ << 1) & 0x1ff   # drops the low bit
    (dead read of a2@ >> 31 discarded)
    d6 = 22
```

off==3 is unreachable for packer-produced streams (data is
long-aligned) but is a genuine decode bug for hand-crafted
headers.

## Bit reader (d6 = low-bit index of next code, signed byte)

```
d6 > 0:   code = (a2@ >> d6) & mask;          d6 -= width
d6 == 0:  code = a2@+ & mask;                 d6 = 32 - width
d6 < 0:   code = (a2@+ << -d6) & mask; d6 += 32;
          code += (a2@ >> d6) & mask;         d6 -= width
```

## Main loop

```
grow:  if nextcode >= threshold && width < bits:
           mask = 2*mask+1; threshold = mask-2; width++; d6--
read code
if code > 0x101:                    -> decode
if out >= out + xsp+16:             -> end check
if code == 0x100 (EOI):             -> end check
if code != 0x101:                   -> decode (literal)
reset: nextcode = 0x102; d6 = (d6 + width - 9), -32 if >=32;
       width = 9; threshold = 0x1fd; mask = 0x1ff; loop
```

Note: the emit-bound check runs only for codes <= 0x101 —
dictionary strings can overshoot the bound by up to 12 bytes
(hence the `produced-12` end check).

## Decode

```
raw = code; depth = 0
if code == nextcode:        # KwKwK
    *--stk = firstchar; code = prevcode; depth = 1
if code > 0x100:            # unwind, STRICT >
    do *--stk = T_char[code]; depth++; code = T_prev[code]
    while code > 0x100       # exits at code<=0x100 INCLUSIVE,
                             # so code==0x100 reads T_char[256]
    firstchar = T_char[code]; *--stk = firstchar
    emit depth+1 bytes (pop loop)
else:
    firstchar = T_char[code]; emit firstchar
    if depth: emit pop
insert: if nextcode < Tsize-2:
    T_prev[nextcode] = prevcode; T_char[nextcode] = firstchar;
    nextcode++
prevcode = raw
```

`stk` = outbuf + xsp+12 (OutBufLen field), descending.
nextcode starts 0x103; resets to 0x102 (one dead slot).
First code emits its LOW byte unconditionally
(`moveb d4,a3@+`).

## Exit

```
produced = out - outbuf
if produced - 12 <= xsp+16: return 0
else: return -14
```

So a stream "succeeds" even when it overshoots the declared
output length by up to 12 bytes.

## State fields used

| xsp offset | use                                        |
|------------|--------------------------------------------|
| +0         | InBuf                                      |
| +4         | (unused by decoder)                        |
| +8         | OutBuf                                     |
| +12        | unwind stack top (descending pushes)       |
| +16        | output bound / declared length             |
| +32        | Password pointer                           |
| +52/+56    | Sub[0]=alloc, Sub[1]=T_char                |
| +60        | Sub[2]=Tsize                               |
| +67        | Sub[3].b = bits                            |

## Stack-in-output artifact

The unwind stack overlaps the output whenever xsp+12 < final
produced length.  Verified on the rnd1k corpus entry with
xsp+12 = 1024: the last string's pushes corrupt output bytes
1021..1023 — identical in the original and the reconstruction.
It is NOT a codec desync; with the stack outside the output
span all streams round-trip cleanly.
