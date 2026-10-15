# xpkZENO 1.1 — packer (XpksPackChunk, 0x30c)

## Gate

```
d1 = xsp_InLen
if (d1 < pc@(0x182)) return -17        # signed long compare
```

The constant at 0x182 is the descriptor's `xi_MinPkInChunk`
= 0x80 — short inputs (< 128) return -17 without any alloc or
output writes.

## Init (Sub[0]==0)

```
Sub[1] = Sub[2] = 0
mode = xsp+31 byte                    # low byte of xsp_Mode
signed clamp: <1 -> 1; >99 -> 99      # cmpb, signed
bits = (mode-1)/33 + 12               # divsw #33
xsp+67 = bits (byte)
D3 = (1<<bits) + 0x800
alloc = AllocMem(7*D3+8, MEMF_CLEAR)
Sub[0] = alloc
Sub[1] = alloc + 4 + 2*D3             # T_pref
Sub[2] = alloc + 8 + 6*D3             # T_char
on alloc == 0:                        # mode-fallback chain
    mode = xsp+31 byte (reloaded RAW, unclamped)
    if mode >= 67:  xsp+31 = 50 -> retry
    elif mode >= 34: xsp+31 = 0 -> retry
    else return -7
```

Retry quirk: the branch re-enters at 0x554, BEFORE the mode
reload — so the first retry allocates at the OLD mode again;
the downgraded byte only takes effect on the next failure.
Fallback chain degenerates to 14b -> 14b -> 13b -> 12b -> -7.

An identical orphan fallback block at 0x5bc is unreachable.

Then: `if (NRD32(xsp_Password) != 0) hv = pwhash(pw) else 0`
(tst.l (a1) — NULL password crashes); `alloc[0..4] = hv`.

## Stream header

```
out[0..4] = hash long
out[4]    = bits
namelen   = 3 - ((out+5) & 3)         # pad to long-align data
out[5]    = namelen
cursor    = out + 6 + namelen         # pad bytes NOT written
out[cursor..4] = 0                    # pre-cleared emit long
xsp+16 (OutLen) = 0
```

## Scan loop

State is swap-packed (d2={nextcode:w}, d5={bitspace:hshift},
d6={width:bound=D3}, d7={maxcode:modulus}); the C model uses
separate variables with identical semantics.

```
first: prevcode1 = *a2++ + 1
loop per input byte b:
    w = (b << (bits-8)) & 0xffff
    h = w ^ prevcode1                  # u16 hash
    if T_pref[h]==prevcode1 && T_char[h]==b -> hit
    elif T_pref[h]!=0:                   # collision chain
        h = (0x7ff + w) & 0xffff
        do h = (h + prevcode1) & 0xffff;
           if h >= D3: h -= modulus    # SINGLE wrap
        while T_pref[h]!=0 && !match
    on hit: prevcode1 = T_code[h]; continue
    on miss:
        emit prevcode1-1
        if nextcode < Tsize-1:
            T_char[h]=b; T_pref[h]=prevcode1; T_code[h]=nextcode++
        prevcode1 = b+1
        checkpoint every 1024 input bytes (below)
        if emit cursor >= outbuf+inlen: return -17
drain: emit prevcode1-1; emit 0x100 (EOI)
OutLen = emit_cursor + 8 - outbuf
```

## Emit (shared subroutine, 0x504)

```
if nextcode >= maxcode && width < bits:
    maxcode = 2*maxcode+1; width++     # grow BEFORE the emit
bitspace -= width
if bitspace <= 0:                      # long boundary cross
    bitspace += 32
    a0@+ += code >> (32 - bitspace)    # top bits into last long
    a0@   = 0                          # pre-clear next long
a0@ += code << bitspace                # += into cleared long
```

## Adaptive reset (per 1024-byte checkpoint)

```
checkpoint = a2 + 1024
threshold  = prevdelta + 128           # recomputed each time
delta      = emit - lastemit
prevdelta  = delta; lastemit = emit
if delta >= threshold (signed):
    prevdelta = 0xfffff                # ~never re-triggers soon
    clear T_pref only (D3/2 longs)     # NOT T_code/T_char
    nextcode = 0x104
    emit 0x101 at the OLD grown width
    width = 9; maxcode = 0x1ff
```

## Table clear

Both the init clear and the reset clear zero ONLY T_pref
(2*D3 bytes from the T_pref base); the alloc is MEMF_CLEAR so
the first clear is redundant, but reset leaves stale T_code /
T_char bytes — unreachable because hits require
`T_pref[h] == prevcode1 != 0`.

## Modulus table (code-resident, hunk+0xb2)

`word[bits-12]`: 0x1003 (12), 0x2011 (13), 0x47fb (14),
0x87f7 (15, dead — modes cap at 14 bits, but the "15 bit" mode
record exists as dead data at 0xbc).
