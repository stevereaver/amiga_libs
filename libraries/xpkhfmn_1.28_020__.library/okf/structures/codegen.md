# xpkHFMN 1.28 — generated decoder (LAB_0039)

The unpacker does not interpret the Huffman tree: LAB_0039 compiles the
serialized tree into 68000 code in workmem, then `jsr (a4)`s it.

## Register contract at `jsr (a4)`

- a0 = data bitstream (right after the `u16 inlen` field)
- a2 = output buffer
- d7.w = inlen
- preserves d5,d6,a3,a5,a6; clobbers d0-d4,d7,a0,a2

## Template (28 bytes copied to wm+0)

```
5347   subq.w #1,d7        ; out counter--
2018   move.l (a0)+,d0     ; 32-bit reservoir load
7410   moveq #16,d2        ; refill budget
7810   moveq #16,d4        ; refill amount
6012   bra.s +28           ; -> root node (skip helper)
9401   sub.b d1,d2         ; helper: budget -= last code length
620e   bhi.s +28           ; enough bits -> root
4402   neg.b d2            ; deficit = overshoot
7600   moveq #0,d3
3618   move.w (a0)+,d3     ; 16 fresh bits
e5ab   lsl.l d2,d3         ; align after remaining valid bits
d083   add.l d3,d0
4402   neg.b d2
d404   add.b d4,d2         ; budget = 16 - deficit
```

## Emitted records

- internal node (6B): `d080 6400 0000`
  `add.l d0,d0` (next bit -> carry) `bcc.w +disp`
  — bit=1: fall through to '1'-side subtree code; bit=0: branch to the
  '0'-side child (disp backpatched to the child's position).
- leaf (12B): `72ss 14c1 72dd 51cf dddd 4e75`
  `moveq #sym,d1` `move.b d1,(a2)+` `moveq #depth,d1`
  `dbf d7, gen+10` (loop via helper) `rts` (dbf-fallthrough exit).

  The leaf's `moveq #depth` charges the consumed bit count into d1 so
  the helper's `sub.b d1,d2` debits the refill budget.

## Generator walk

Reads the tree bitstream with its own reservoir (`move.l` + addx
sentinel at bit0; on empty, reload keeps the pending bit in X as the
new bit0 marker — sentinel re-seats, next bit = fresh bit31).

- '1' marker: if a leaf just closed (d1 flag), first pop one
  right-pending ancestor and patch its bcc to HERE, then push the new
  node {ptr, serial++} and emit it inline (left/'1' path).
- '0' marker + 8 bits (LSB-first assemble): emit leaf inline when
  continuing, or pop+patch+emit after a leaf.
- stack underflow (serial count < 0) = tree complete; the trailing
  pad bits guarantee termination.
- fixup stack entries at wm+0x13fa, 6B each {u32 node ptr, u16 serial}.

Bit positions: leaf sym byte is written at emit+1 (`move.b d2,-3(a1)`),
depth byte at emit+1 of second moveq, dbf disp at emit+8 —
disp = (gen+12)-(emit+10) so target = gen+10 (`sub.b`).
