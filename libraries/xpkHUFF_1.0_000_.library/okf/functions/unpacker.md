# XpksUnpackChunk (-54) — unpack algorithm

## Entry checks

- `tst.w (in)` — flag word must be 0 else **-26**.
- `cmpi.l #$ABADCAFE,(a1)` at stream **offset 0** — intended to
  detect the plaintext marker (which actually lives at offset 2),
  but the flag word there must be 0, so this can never match:
  the `+inlen` alloc bump is taken unconditionally (defect).
- Lazy `AllocMem(memsz)` into `xsp_Sub[0]`, same size-prefix
  scheme as pack.  Reuse check (`tst.l 52(a3)`) ignores size —
  a pack-allocated 0x3208 buffer is too small for
  `0x1004+inlen` when inlen > 0x2204.
- `d2 = *(u32*)(in+2)` = hash field.  `0xABADCAFE` -> plaintext
  path.  Otherwise `xsp_Password` must be non-NULL (**-32**)
  and `pwhash(pw)` must equal the stored field (**-32**).

## Descramble (password streams)

`d0 = inlen-1` via `move.l`/`subq.w` then `dbf` — **inlen**
iterations starting at `in+6`, i.e. it reads ~6 bytes past the
input buffer end.  Output goes to `a5+0x1000`:

```
d3 = pw[0]                       ; prev_cipher seed
per byte: c = *ip++; k = *pp++ (cycle on NUL);
          plain = (c - d3) ^ k;  *dst++ = plain;  d3 = c
```

Then `ip = a5+0x1000` — table+data are read from the
descrambled copy.

## Trie build

Root node at `a5+0`, nodes are 4-byte `{u16 child0@0, u16
child1@2}` word-offsets from a5; `next` allocator starts at 4
and bumps by 4.  Per symbol: table byte `0xFF` skips, else the
byte is `len-1`; `ceil(len/8)` code bytes are read MSB-first
and left-justified (`lsl.l 32-8*nb`), then `len` bits walk the
trie (bit=1 -> word@2).  Leaf = long `0xFFFFFF00|sym` written
over the final node — negative = leaf discriminator.

`tst.w 2(a5); bne skip; move.w (a5),2(a5)` — when the root's
'1' side is empty it mirrors the '0' side, so single-symbol
tables decode either bit.

## Fast table (a5+2048, 1024 x u16)

For each index `i` (stepping `d2 += 0x40`, i.e. `i = d2>>6`
covering all 1024), walk the trie along `i`'s 10 bits
(`add.w d0,d0` — bit15 = prefix MSB).  If a leaf is hit at
iteration k: entry = `{u8 d1=10-len, u8 sym}` (two byte stores).
If the 10 bits exhaust at an internal node: entry = `u16
nodeoff-0x800` — negative, and doubles as an `a4`-relative
offset since `a4 = a5+0x800`: `a4+entry = a5+nodeoff`.

## Decode

State: `d7` = left-draining bit buffer (refill `lsl.l #8;or.b`),
`d6` = buffered-bits-minus-10 bookkeeping, `d4 = outlen-1`
(subq.l then dbf — **low word only: outlen>=65536 wraps**).

Per symbol:
1. `d6 -= 10`; while `d6<0` refill a byte and `d6 += 8`.
2. `d0 = (d7 >> d6) & 0x3FF` — next 10 stream bits.
3. `e = s16 tab[d0]`; if `e >= 0`: emit `e&0xFF`, `d6 += e>>8`
   (the unconsumed suffix refund — net -len).
4. Else deep path: `d0 = *(u32*)(a4+e)` = the depth-10 node
   (via the negative-offset trick); then per bit: `dbf d6`
   (refill+d6=7 when it hits -1), `btst d6,d7` picks the child
   word (set -> low/'1', clear -> swap to hi/'0'),
   `move.l 0(a5,d0.w)` loads child content; `dbmi` exits on
   leaf (N flag — **DBcc does not modify CCR**, so the MOVE.L's
   sign flag survives for the exit test and the `bpl` refill).
   Leaf's low byte is emitted.
5. `dbf d4` — loop until outlen symbols produced.

Success returns 0.
