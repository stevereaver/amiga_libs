# Vector map (functab @ 0xb4, offsets relative to 0xb4)

Table: `ffff` marker, 10 word entries, `ffff` terminator.

| LVO | entry | target | function |
|-----|-------|--------|----------|
| -6  | +0x0020 | 0x0d4 | Open: `opencnt++`, clear delayed-expunge bit (flags@14 bit3), return libbase |
| -12 | +0x002e | 0x0e2 | Close: `opencnt--`; if 0 and expunge bit set -> fall into Expunge |
| -18 | +0x0040 | 0x0f4 | Expunge: if opencnt -> set expunge bit, return 0; else Remove, FreeMem(lib-negSize, size+dataSize), return seglist@34 |
| -24 | -0x0094 | 0x020 | entry stub `moveq #0,d0; rts` |
| -30 | +0x00ea | 0x19e | XpksPackerInfo: `lea _xpkinfo; move.l a0,d0; rts` |
| -36 | +0x00f2 | 0x1a6 | XpksPackChunk (LIBFUNC_2) |
| -42 | +0x007e | 0x132 | XpksPackFree (LIBFUNC_3): frees Sub[0]-4 with stored size; leaves Sub[0] stale |
| -48 | +0x0096 | 0x14a | XpksPackReset (LIBFUNC_4): clears the 65536-entry hash head table; also called internally at the top of every PackChunk |
| -54 | +0x034e | 0x402 | XpksUnpackChunk (LIBFUNC_5) |
| -60 | -0x0094 | 0x020 | entry stub |

## LibInit (@0xcc)

```
movea.l d0,a1        ; libbase
move.l  a0,34(a1)    ; store seglist
rts
```

No CPU gate (68000 build). Returns d0 = libbase.

## PackChunk (LIBFUNC_2 @0x1a6) — algorithm

1. `bits` from `xsp_Mode` (+28) via a threshold chain:
   `mode<=1:2, <=10:3, <=20:4, <=30:5, <=40:6, <=50:7, <=60:8,
    <=70:9, <=80:10, <=90:11, <=98:12, else 13`
2. If `Sub[0]` unset, AllocMem `(1<<bits)*4 + 0x40004` (flag 0);
   stores the size in the first long, `Sub[0] = alloc+4`.
   Fail -> return **-7**.
3. Call LIBFUNC_4: clears the hash head table
   (`Sub[0] .. Sub[0]+0x40000`, exactly 0x40000 bytes).
4. Write `bits` as the first output byte, then token loop:
   - 3-byte hash `h = (b0<<8) | ((b1+b2)&0xff)` (byte add wraps).
   - `cand = head[h]`; walk `chain[cand & mask]` while
     `cur-cand <= mask`; quick-reject on `cur[len]!=cand[len]`,
     else full `cmpm` compare up to `min(0x101, rem)` bytes.
     Best match kept as `d5 = dist<<16 | len`.
   - len<3: literal run++ (cap 0xfff -> forced flush), insert pos.
   - flush: lits<21 -> each byte 9 bits (`'0'+b`); else
     `('1'+0(8)+count(12))` then raw bytes.
   - match: emit `'1' + (len-2)(8b) + dist(db)` where
     `db = distbits(min(pos, mask))` via the 13-entry table.
   - insert `len` positions into the hash.
5. On `nbits` leftover at end: left-justify into a byte and store.
   Output overflow (`out >= outbuf+inlen`) inside emit -> return **-17**.
   Success -> `xsp_OutLen` (+16), return 0.

### Bit plumbing

- Packer emits each token value least-significant bit first
  (`lsr.l #1,d0 / addx.l d3,d3`), accumulator flushed MSB-first —
  so the stream order equals token LSB -> MSB.
- Decoder `getbits(n)` reads bytes MSB-first and assembles the
  value with the **first stream bit in result bit 0** (ROXR into
  bit31, final `lsr (32-n)`) — i.e. the same LSB-first
  convention, so all fields pass through verbatim.
- Decoder token layout:
  - `0` -> literal byte (8 bits).
  - `1`, then 8-bit field t:
    - `t==0` -> literal run: 12-bit count, then count raw bytes.
    - else -> match: `dist` in `distbits(min(outpos,mask))` bits,
      copy `t+2` bytes from `out-dist`.

## Stream format summary

```
byte0      window bits (2..13)
repeat:
  '0' b[8]              literal
  '1' (len-2)[8] dist   match, len<=257
  '1' 0[8] count[12]    long literal run (count raw bytes)
pad to byte boundary
```

## UnpackChunk (LIBFUNC_5 @0x402)

Reads `xsp_OutLen` (+16) as the stop condition (`out == end`).
No input bounds check, no work memory. `d4 = (1<<in[0])-1`.
