# XpksPackChunk (-36) — pack algorithm

## Workmem

Lazy `AllocMem(0x3208)` (flags 0, NOT cleared) on first call,
size-prefix at alloc+0, body pointer at `xsp->xsp_Sub[0]`.
Subsequent calls reuse it unconditionally.

## Flow

1. `a5 = Sub[0]`; `move.l sp,(a5)` saves the stack pointer —
   the emit-budget bailout longjmps here.
2. Clear the 512-byte histogram region at `a5+11268` (8 x
   `movem.l d0-d3,-(a1)` x 8 from `a5+11780` downward).
3. Histogram: plain byte counts into u16 slots at
   `a5+11268` (the same memory later reused as the len table).
   Count is `inlen-1` via `subq.w`/dbf — **inlen 0 wraps to
   65536 samples** and reads far past the input.
4. Build sorted leaf list in the node arena at `a5+26`
   (22-byte nodes): symbols 255->0, before-equals insert by
   ascending frequency (`bhi` = continue while new > node).
   Head slot at `a5+4`.  `st 6(a4)` writes a 0xFF sentinel byte
   at the next slot's sym field.
5. Merge two smallest into internal nodes (marker `0x4000` on
   the '0' side = first popped = smaller freq; `0x8000` on the
   '1' side), reinsert before-equals into the remaining list.
   Single-leaf input gets a pseudo-root with only `left@12`
   set and the leaf marked 0x4000 (code = single '0' bit).
   Root's mark is cleared to 0.
6. Code build: walk each leaf's parent chain; each mark's
   bit15 is rotated into the code MSB-first (`roxr.l`), so the
   accumulated code is root-first at the top; `lsr.l d1`
   right-justifies.  Depth>32 aborts via the bailout.
   `lentab[a5+11268]` = u16 length, `codetab[a5+11780]` = u32
   right-justified code.
7. Emit:
   - u16 flag `0`, then hash/0xABADCAFE — written BEFORE any
     budget check (the -7 upfront reserve covers them).
   - Per symbol 0..255: len 0 -> `0xFF` byte; else byte
     `len-1` + ceil(len/8) code bytes, code left-justified and
     emitted top-byte-first (`rol.l #8` + byte store).
   - Data: bit accumulator `d7` MSB-first, `d6` = free space;
     `sub.w len,d6; lsl.l d6,d0; or.l d0,d7` then flush while
     `d6<24`: top byte out, `d6+=8`.  len>16 splits into
     (len-16) hi bits + 16 lo bits.
   - Final partial byte emitted when `d6!=32`.
8. `xsp->xsp_OutLen = written`.
9. If `xsp->xsp_Password`: in-place scramble of out[6..outlen)
   with `c = (plain ^ pw[i]) + prev_cipher`, pw cycled on NUL,
   prev_cipher seeded with `pw[0]`.  `dbf` on `outlen-7` wraps
   for tiny outputs — unreachable in practice (table >= 257B).

## Bailout

Every emitted byte does `subq.w #1,d5; bcs bail` — the budget
is `u16(inlen)-7` (a WORD register — only the low 16 bits of
inlen count).  The flag+hash consume none.  Bailout restores
SP from `a5+0`, pops the reg block and returns **-27** when
`xsp_Password` is set, else **-17**.  `inlen<7` bails before
the flag word is written.

## Password hash

```
d0 = 0xABADCAFE; d1 = 0xC0DE
per char:  d1.b = c;  d0 += d1  (word add; NUL exits first)
swap d0
per char:  d1.b = c;  d0 ^= d1 (word); d0 = rol.w(d0,8)
```

Note `move.b` only reloads `d1.b` — the 0xC0 high byte persists,
so every character contributes `0xC0|c`, not `c`.  The same
routine runs on both sides, so hashes match; e.g. `"secret"`
-> `0x4D840818`.
