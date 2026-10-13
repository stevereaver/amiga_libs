# xpkBZIP — defects and quirks (all reproduced)

## out[0] written before the level range check

PackChunk stores the computed mode byte into `dst[0]`
*before* validating `1 <= mode <= 10` — an invalid level
still clobbers the output buffer's first byte (verified:
level 101 → -12 AND out[0]=11; level 200 → -12 AND
out[0]=20).

## Lazy alloc gate requires ALL THREE zero

Work buffers are (re)allocated only when `!buf52 &&
!buf56 && !buf60` — a partially-freed set (e.g. one buffer
present, two NULL) skips allocation entirely and proceeds
to dereference the NULLs on the PPC side.  Verified: a
(X,0,0) set → not reallocated → -7 on the post-check.

## PackFree returns a residue, not 0

Vector -42 is byte-identical to the shared free helper and
lacks UnpackFree's trailing `moveq #0,d0` — its return is
whatever the last ppc -66 FreeVec left in d0 (verified
0xdeadbeef propagates through -42; -60 returns 0).

## Mid-instruction moveq #0 branches

Both LibClose and UnpackChunk end with a dead
`cmpi.w #0x7000,d0` whose operand bytes `70 00` double as
`moveq #0,d0` — the early-exit/success paths branch into
the middle of the cmpi instruction.

## Dead range-check half

`mode < 1` in PackChunk can never fire — mode is already
clamped to ≥1 by the `if(!mode) mode=1` above it.

## Mode-list chain is backward

The 10 XpkMode records are stored "1000 K"→" 100 K" but
each `xm_Next` points at the PREVIOUS record and
xi_ModeDesc anchors the last one — the xpk-visible order
is " 100 K" first.

## Block-size units

`mode * 102400` bytes (not 1024-based): mode 10 =
1,024,000 = xi_MaxPkInChunk.  The K-suffix names are
decimal-kB.

## 68020+ requirement

Uses `divu.l`/`mulu.l` (level/10 and mode*100 math) — the
binary cannot run on a plain 68000, consistent with its
PowerUP host requirement.
