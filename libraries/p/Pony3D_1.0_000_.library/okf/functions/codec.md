# Pony3D.library — internals

## Trig table (DATA hunk +0xa6, 512 words)

    tab[0..255]   ≈ -sin(i·2π/256)·256   (negated sine, 8.8 fix)
    tab[256..511] ≈  cos(i·2π/256)·256

Indexed by byte offset: `tab[a]` as a WORD read at
`tabbase + a` — the angle register (even, 0..510 after the
+2 bias and &511 mask) doubles as a byte offset, so
`sin(a) = tabwords[a/2]`, `cos(a) = tabwords[256 + a/2]`.
Odd angle inputs would produce misaligned word reads
(address error on 68000) — API contract is even angles.

Values deviate ±1 from ideal `round(-sin·256)`/`round(cos·256)`
(ASM-One table generator rounding); embedded verbatim in the
reconstruction.

## Fixed-point math

`mulsw` 16×16 → 32-bit signed product; pairs combined with
`addl`/`subl`; `asrl #8` arithmetic shift — standard 8.8
fixed point (input units × table value /256).  `divsw`
32/16 signed division.

## Rotation axes

Three pair-rotations per vertex in sequence: (y,z) by ax,
then (x,z) by ay, then (x,y) by az — Euler XYZ order.

## CLI bootstrap (hunk0+0, runs the file as a command)

    OpenLibrary("reqtools.library", 38)        ; -552
    fail → dos path
    obj = vec -30 (d0=1, a0=0)                 ; alloc request
    fail → CloseLibrary(rt) → FALL INTO dos path
    obj[0]  = 1                                ; type/flag
    obj[12] = "Pony3D.library"  (relocated ptr — title)
    bset #2, obj[16]                           ; flag bit
    vec -66 (a0=0, a1=credits, a2="OKAY", a3=obj, a4=0)
    vec -36 (a1=obj)                           ; free request
    CloseLibrary(rt); restore regs; return 20

dos fallback (+0x88):

    OpenLibrary("dos.library", 0)
    fh = vec -60 (Output)
    vec -48 Write(fh, idstr, *(h0+0x16a) = 119)
    CloseLibrary(dos); return 20
    — QUIRK: this path never restores the moveml'd d0-a6,
      so it returns with 56 bytes still on the stack and the
      caller's next rts jumps to the saved a6 (wild return).

The reqtools function numbers map to its requester API
(-30 alloc, -66 show-with-text+gadget, -36 free); exact
public names not needed for reconstruction.

## LibInit stack leak

    push a5; a5=d0(lib); lib+38=a0(seg); lib+34=a6(sys);
    d0=a5; braw +2  → skips `moveal sp@+,a5` → +4 stack leak
    rts
