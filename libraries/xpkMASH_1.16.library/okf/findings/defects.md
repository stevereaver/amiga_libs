# Defects & quirks — xpkMASH 1.16

## 1. Len-2 matches at distance >= 512 corrupt the stream (fatal)

The len-2 match token bypasses the classed `emit_dist` path and emits
`d3 << 5` as a single 11-bit field — i.e. `dist[10:0]` raw, where the
top 2 bits double as the `00` token selector the decoder needs to see.
For `dist < 0x200` those top bits are 0 and the token reads `00` +
9-bit dist as intended; for `dist >= 0x200` bit(s) 9-10 are set, the
decoder parses a different token type entirely, and the stream desyncs
permanently (output diverges from that match onward).

Confirmed empirically: every packed stream containing a `len2` token
with `dist >= 512` decodes corrupt from that token onward, in BOTH the
original (instruction-level simulated) decoder and the reconstruction —
the first divergence point matches exactly on every test input.  ~9 of
36 stress inputs exhibit it.  This is presumably why the author shipped
V1.98 shortly after ("good packer").

The reconstruction reproduces the defect bit-exact on purpose.

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
