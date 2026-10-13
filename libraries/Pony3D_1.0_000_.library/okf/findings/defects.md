# Pony3D.library — defects and quirks (all reproduced)

## ProjectPoints center decay (functional bug)

`divsw #2,d1` and `divsw #2,d2` sit **inside** the per-vertex
loop — cx and cy are halved once per vertex, not once per
call.  Projection of n points uses cx/2^i for the i-th
point; the center collapses to 0 within ~16 iterations.
Worse, `divsw` leaves the remainder in the register's high
word, so odd inputs feed rem:quot garbage into the next
halving (verified — odd cx diverges chaotically yet
identically between original and rebuild).

## CLI dos-fallback wild return

The fallback path (no reqtools.library, or a failed request
alloc that falls through) never executes `moveml (sp)+,d0-a6`
— it returns with 14 saved registers still on the stack.
The next `rts` in the caller jumps to the saved `a6` value —
a wild return/crash.  Works "well enough" in practice
because the dos Write runs before the corrupted return.

## LibInit stack leak

`braw +2` after the data stores jumps **over** the
`moveal sp@+,a5` — a5 is never restored and the return to
InitResident leaves a stale longword on the stack (4-byte
leak per MakeLibrary call, harmless in practice).

## datatab dead init

`a0 0c 09` writes byte@12=9 — inside the ln_Name field,
immediately clobbered by `80 0a` writing the name pointer.
Plus ln_Type is never set (stays 0, not NT_LIBRARY=9).

## List count is a last-index

All four API loops use the count word as a `dbf` counter →
count+1 elements processed.  `count=0` still processes one
element; there is no zero-list fast path.  Callers must
store `n-1`.

## ProjectPoints z clamp

`z==0` is patched to +1 via `addiw`, but other degenerate
values pass through: z=-1 divides fine (flips sign), and the
addiw only fires on exactly 0.

## Plot has no clipping

`y*40 + (x>>3)` byte offset, `bset (~x)&7` — out-of-range
coordinates write to arbitrary memory (y·40 wraps mod 64K
via `muluw`+word index, x>>3 is a logical shift making
negative x positive-large).

## Angle bias

Rotate adds +2 to each angle at entry and masks to 512 —
the "angle" API unit is table byte-offsets (2 per table
entry over a 256-entry full circle ≈ 1.4°/unit), with the
+2 presumably compensating caller convention or acting as a
fixed speed bias.
