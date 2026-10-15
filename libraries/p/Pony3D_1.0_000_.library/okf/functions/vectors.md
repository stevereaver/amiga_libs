# Pony3D.library — vectors and ABI

8 vectors, absolute-longword functab.  All vertex lists use
the `[count][elements]` format with dbf semantics (see
quirks): the count word is the loop counter minus one —
**count+1 elements are processed** (count = last index).

## Lifecycle

### -6 LibOpen
`opencnt++` (word@32), `bclr #3,14` (DELEXP), returns a6.
### -12 LibClose
`opencnt--`; if 0 and DELEXP set → tail LibExpunge; d0=0.
### -18 LibExpunge
opencnt!=0 → `bset #3,14`, return 0.  Else Remove,
FreeMem(neg+pos), return seglist (lib+38).
### -24 Reserved
`moveq #0,d0; rts`.

## -30 RotatePoints(src:a0, dst:a1, ax:d4, ay:d5, az:d6)

Vertex format `[count][x,y,z]*` (words, in=count+1 triples).
At entry: `ax = (ax+2)&511` etc (the +2 bias, mod 512).

Per vertex, three pair rotations with the trig table
(`SIN(a)=tab[a/2]`, `COS(a)=tab[256+a/2]`, a = byte offset):

    z' = (y*COS(ax) - z*SIN(ax)) >> 8   ; about X
    y' = (y*SIN(ax) + z*COS(ax)) >> 8
    x' = (x*COS(ay) - z*SIN(ay)) >> 8   ; about Y
    z' = (x*SIN(ay) + z*COS(ay)) >> 8
    x' = (x*COS(az) - y*SIN(az)) >> 8   ; about Z
    y' = (x*SIN(az) + y*COS(az)) >> 8

Products are `mulsw` (16x16→32 signed), combined as longs,
`asrl #8`, truncated to word.  Writes count + count+1
rotated triples to dst.

## -36 TranslatePoints(src:a0, dst:a1, dx:d0, dy:d1, dz:d2)

    out = (x+dx, y+dy, z+dz)   ; word adds, wraps

## -42 ProjectPoints(src:a0, dst:a1, f:d0, cx:d1, cy:d2)

Writes `[count][sx,sy]*` (2D points, count+1 of them).
Per vertex, IN THIS ORDER:

    cx = divsw(cx, 2)          ; EVERY iteration — decays!
    cy = divsw(cy, 2)
    if (z == 0) z = 1          ; addiw, only on exactly 0
    sx = (x*f)/z + cx.w
    sy = (y*f)/z + cy.w

The `divsw` is a full-register op: quotient lands in the low
word, **remainder in the high word** — so after odd values
the next halving divides rem:quot garbage.  `cx` converges
to 0 within ~16 iterations for even starts.  `x*f` is
`extl`+`mulsw` (32-bit product), `divsw` 32/16.
z = -1 (or any nonzero) passes through unclamped.

## -48 Plot(list:a0, plane:a1)

`[count][x,y]*` — sets `plane[(UWORD)(y*40) + (UWORD)(x>>3)]
|= 1 << ((~x)&7)` — 40-byte-pitch (320px) rows, MSB-first
Amiga bit order.  No clipping — negative/huge coords write
wild memory.

## Function names

No public includes survive; names above are descriptive
(matching the obvious semantics).  The (FPU) sibling likely
keeps the same LVO order.
