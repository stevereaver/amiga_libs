# ksort.library — vector map

Absolute-longword functab at hunk0+0x8c, 11 entries +
0xffffffff terminator.  NegSize = 66 (11×6), PosSize = 76
(34+0x2a).

## Lifecycle vectors (hunk0)

### -6  LibOpen — h0+0x150
```
addq.w #1,32(a6)        lib_OpenCnt++
bclr   #3,14(a6)        clear LIBF_DELEXP on the library
move.l a6,d0            return lib
```

### -12 LibClose — h0+0x15e
```
d0=0; subq.w #1,32(a6); if cnt==0 && DELEXP -> bsr LibExpunge; rts
```

### -18 LibExpunge — h0+0x172
`movem.l d2/a2/a6,-(sp)` then **`tst.w 0x20(a5)`** — tests
OpenCnt through the caller's a5 (never loaded) — wild read.
Nonzero → `bset #3,14(a6)` (DELEXP on the lib — correct target
this time) → return 0.  Zero → Remove(lib), FreeMem(lib-neg,
neg+pos), then three `CloseLibrary` calls on the **name
strings** (a1="dos.library" etc. — never the opened bases),
storing each residual d0 into the BSS base slot, then
`move.l d2,0` — writes the seglist to **absolute address 0**
(the operand is not relocated — a missing h1 relocation),
then returns the last CloseLibrary residue (never the
seglist).  See findings/defects.md.

### -24 Reserved — h0+0x214
`moveq #0,d0; rts` — proper null stub.

## Public API vectors (hunk2)

Every sort entry is an identical 32-byte wrapper:
```
movem.l d2/d7/a2,-(sp)
lea    0(a6),a0        a0 = libbase (unused by workers)
movea.l d0,a2          a2 = array
move.l  d1,d7          d7 = count
move.l  d7,d0; subq.l #1,d0; move.l d0,d2   d2 = count-1
move.l  a2,d0          d0 = array
moveq   #0,d1          d1 = lo = 0
bsr     worker
movem.l (sp)+,d2/d7/a2; rts
```
So each public entry calls `worker(array, lo=0, hi=count-1)`.
`a6` must be the library base (vector ABI), but the workers
only use it to recompute `a0 = a6` which is never consumed —
the sort routines are effectively base-free.

| LVO | Worker   | Frame | Element    | Compares          |
|-----|----------|-------|------------|-------------------|
| -30 | h2+0x020 | -4    | BYTE  (s8) | signed (blt/bgt)  |
| -36 | h2+0x0c8 | -4    | UBYTE (u8) | unsigned (bcs/bhi)|
| -42 | h2+0x170 | -24   | WORD  (s16)| signed            |
| -48 | h2+0x242 | -24   | UWORD (u16)| unsigned          |
| -54 | h2+0x314 | -28   | LONG  (s32)| signed            |
| -60 | h2+0x3dc | -28   | ULONG (u32)| unsigned — AND    |
|     |          |       |            | UNSIGNED INDICES  |
| -66 | h2+0x4a4 | -24   | char*      | jsr stricmp       |

The u32 worker additionally uses unsigned comparisons for its
index tests (`bls/bhi/bcc` instead of `ble/bgt/bge`) — the
root of its wild-write defect.

## Comparator (hunk3, 60 bytes)

`stricmp(s1:stack, s2:stack)` — classic C-stack-args helper:
reads byte pairs, ASCII-folds 'a'..'z' to uppercase
(`cmpi.b #0x61/0x7a`, `subi.b #0x20`), returns `c1-c2`
(LONG in d0; 0 on equality).  The hunk2 string worker reaches
it through a `jmp (h3+0)` tail stub at h2+0x570 (the single
hunk2→hunk3 relocation).
