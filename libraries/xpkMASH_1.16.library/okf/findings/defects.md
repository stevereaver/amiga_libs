# Defects & quirks — xpkMASH 1.16

## 1. Len-2 matches at distance >= 512 are silently dropped

The len-2 match token bypasses the classed `emit_dist` path and emits
`d3 << 5` as a single 11-bit field — i.e. `dist[10:0]` raw, where the
top 2 bits double as the `00` token selector.  A `dist >= 0x200` would
therefore decode as a different token type entirely.

But such tokens are never emitted: `find`'s exit does
`subq.w #2,d3` and — for len-2 only — `move.l d3,d0; addi.l
#0xfe000000,d0`.  That "dead" add sets the carry flag iff
`dist >= 0x200`, which lands in the caller's `BCS` and marks the
match as *not found*.  The packer simply loses profitable len-2
matches at far distances (output stays valid, ratio suffers).

The reconstruction models this in `find`'s return (len-2 with
dist >= 512 returns no-match).

## 1a. > 64 KiB inputs: distance arithmetic wraps mod 64 KiB

`find` computes `dist = pw - cand.w` on pointer LOW WORDS (and the
chain table is indexed by `pw*2` sign-extended).  When the input
buffer spans a 64 KiB address boundary, positions past the wrap have
small low words again, so `pw - cand` for candidates before the wrap
comes out negative/wrong — the emitted distance points at the wrong
source and the stream decodes corrupt from there.  Reproduced via the
same low-word arithmetic; on host it additionally makes packing
nondeterministic (malloc'd base low-word varies run to run).

## 1b. > 64 KiB inputs: packer can hang on a delta-0 self-loop

When `insert` runs at a position whose low-word equals the value still
stored in `head[h]` — inevitable past the 64 KiB wrap, since heads
hold stale low-words — it writes `CHAIN[pw] = 0`.  A later chain walk
landing on that entry does `cand -= 0` and spins forever.  Verified on
the V1.26 port (`D0LOOP at cur=132361 cand=131072`); the same insert
and walk exist here.  Hash/heap-layout dependent: when it doesn't
fire, >64KB output is just corrupt per 1a.

## 2. Chain table sign-extension aliasing

`chain` base = `alloc1 + 0x8000`; index = `a2@(0,d1:w)` —
sign-extended `pw*2`.  Pointer low words >= 0x8000 index into the
LOWER half of alloc1, aliasing mod 0x8000.  On 24-bit-address machines
this wraps every 32KB of address space.  Reproduced via
`*(UWORD*)(chain + (WORD)(pw*2))`.

## 3. Block-clear underwrites

`filldown` clears N×0x100 bytes downward including one extra block:
alloc1 init writes `alloc1-0x100 .. alloc1+0xffff` (underwrites the
allocation by 0x100 bytes); alloc2 init writes `alloc2-0x100` … — heap
metadata corruption under real AllocMem.  Reproduced faithfully;
the host harness pads allocations.

## 4. `emit_dist` table walk is unbounded — unreachable in practice

Dist classes are cumulative boundaries 0x20,0xa0,...,0x3ea0,0x7ea0;
a distance >= 0x7ea0 (32416) would walk `i` off the 8-entry `distw`
table and read adjacent rodata.  In practice unreachable: the chain
ring (position mod 0x8000, sign-extended) clobbers candidates ~32K
positions back before the window bound does, and observed max emitted
distance is ~32.2K.  Reproduced faithfully regardless.

## 5. Decoder trusts the stream completely

- Unary walks (`lclass`/`dclass`/`rclass` tables) have no bound: a
  desynced stream walks off the table into adjacent hunk memory.
- `copy dist` reads `out-dist` with no validation — distances > bytes
  emitted read before the output buffer.
- The literal-copy loop and match copy write past `outend` by up to
  len-1 bytes (outer guard only gates token starts).
- Excess bits are never checked; trailing garbage is silently consumed.

Host harness adds 0x8000 head/tail padding; the m68k code is verbatim.

## 6. Output bound = inlen - 50

Any input that can't shrink by 50 bytes fails -17 (all inputs < ~51
bytes, and anything incompressible).  `xsp_Bound` is also *stored into
the caller's params* (+0x3c) — a side effect visible to the caller.

## 7. Lazy-match asymmetry

The lazy lookahead compares `prev >= nx` on 16-bit packed lengths —
a tie prefers the current match (reasonable), but the lookahead call
also *inserts* `cur+1` into the hash even when the current match is
chosen — i.e., position cur+1 is hashed before the match at cur is
emitted, then inserted AGAIN by the post-match insert loop (harmless —
second insert just rewrites head/chain).
