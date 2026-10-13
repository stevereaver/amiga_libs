# xpkTDCS 1.2 — codec algorithm

## Encoder (XpksPackChunk, -36)

Setup: `d4=cur, d5=remaining=InLen, a3=out=OutBuf+4` (the first
flag long slot is reserved up front), flagslot=out-4,
flagacc=0, bitcnt=15, outend=OutBuf+InLen, table = 65536
{cap,blk} pairs in a fresh exec pool (CreatePool(0,0x8000,
0x1000), AllocPooled(0x80000), zeroed).

### find(cur) — hash + per-bucket position array

```
key = ((cur[0]<<8)|cur[1]) ^ cur[2]        # eorl of word+byte
e   = &tab[key*2]
if e.blk == 0:                              # virgin bucket
    e.blk = AllocPooled(16); e.cap = 2; blk[0]=0; return 2
used = blk[0]
drop stale prefix: while blk[1+i] and cur - blk[1+i] > 65535
    (oldest-first walk of the stale PREFIX, stop at first
     in-window); memmove survivors down; blk[0] = used-drop
best = 2
for i = used-1 .. 0:                        # newest -> oldest
    c = blk[1+i]
    if cur[best-1..best] != c[best-1..best] continue   (word)
    if cur[1..2]      != c[1..2]      continue         (word)
    len = 6; s = cur+3; c += 3
    repeat: read long *s++, *c++ ; if differ break
            len += 4; if len > 260 break
    # post-increment semantics: on mismatch s/c are ALREADY 4
    # past the failing long -> back up 4 for tail refinement:
    s -= 4; c -= 4
    if word(s)==word(c): s+=2,c+=2 else len-=2,s-=2,c-=2
    if byte(s)!=byte(c): len--
    if len <= best continue
    best = len; dist = c - cur  (negative)
    if best >= 257: best = 258; break        (bhis, see oracle note)
return best
```

### lazy chain (per emitted item)

```
len = find(cur)
if len <= 257:                      # >257 emits immediately
    loop:
        cur++
        llen = find(cur)            # full side effects
        if llen - 1 <= len: cur--; break     # reject
        len = llen; dist = ldist             # adopt
        cur--
        insert(cur); *out++ = *cur; cur++;   # literal for old cur
        remaining--; emit flag-00 (bitcnt--)
        if out > outend: return -17          # strict > here
        if len >= 257: break                 # emit now
```

The stack slots: `sp82(lo=sp84)` = lookahead len,
`sp78(lo=sp80)` = lazy pass count d6 (always 1 at the gate),
`sp74(lo=sp76)` = pending len — the gate is
`llen - d6 <= pending → reject`.

### emit + insert

```
if len >= (SHORT)remaining: len = (SHORT)remaining   # sp@150 alias
if len < 3: literal byte (flag 00); len = 1
else:
    l3 = len - 3
    if l3 <= 3  && dist >= -16385: word = (dist<<2)|l3   (flag 01)
    elif l3 <= 15 && dist >= -4097: word = (dist<<4)|l3  (flag 10)
    else:                            word dist + byte l3 (flag 11)
flagacc |= tag << (bitcnt*2)
remaining -= len
insert len positions starting at cur (see below); cur += len
if --bitcnt < 0: flush flagacc to flagslot; flagslot=out; out+=4
if out >= outend: return -17                          # bhis
if remaining > 0: loop
else: flagacc |= 3<<(bitcnt*2); flush; write zero word; OutLen
```

### insert(pos)

```
e = &tab[key(pos)*2]
if e.cap == 0: blk = AllocPooled(16); cap=2; blk={1,pos}; ret
blk[1+used] = pos; used++
if used >= 259 && cur - blk[used-259] == 259:
    used--; copy 516 longs down (overrun; blk[0] corrupted)
grow:  cap <= used  -> d7 = cap<=63 ? cap : 64
shrink: cap > used  -> d7 = (used>1 && cap/2>=used && cap>64)
                        ? -64 : 0
if d7: nb = AllocPooled((cap+d7)*4+8); copy 2*used longs
       (overrun); FreePooled(blk, cap*4+8); cap += d7; blk = nb
blk[0] = used
```

## Decoder (XpksUnpackChunk, -54)

```
loop:
    flag = read long
    if flag == 0: copy 16 literal bytes (4 movels); continue
    16 items, 2 bits each MSB-first:
      00: literal byte
      01: tok word; d = (s16)tok >> 2; len = (tok&3)+3
      10: tok word; d = (s16)tok >> 4
          f = tok&15: f==0 -> len 3 ; else len = (f&7)+3 then
          f>>3 extra blocks of 8        # = (f&7)+3 + 8*(f>>3)
      11: tok word; tok==0 -> return   (terminator)
          d = (s16)tok; len byte: (b&7)+3 + 8*(b>>3)
```

Distances decode as `dst + d` with d negative (backward copy),
overlapping allowed (byte-at-a-time LZ77 semantics — the copy
loops are `moveb a0@+,a2@+` so periodic self-references work).
No output bound, no input bound, no OutLen writeback.

## A note on decoder sign extension

`moveq #-1,d1` runs before the item loop, then `movew a1@+,d1`
per token.  `movew` to a data register preserves the upper 16
bits, so `d1 = 0xffff0000|tok` = sign16(tok) — `asrl` and
`lea dst@(0,d1:l)` then yield signed/negative distances.  Easy
to misread as unsigned/forward (the disasm shows `lea
a0@(0,d1:l)`); verified empirically via the oracle.
