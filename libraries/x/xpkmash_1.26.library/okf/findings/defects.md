# Defects & quirks — xpkMASH 1.26

Most are inherited verbatim from V1.16 (see
`../../xpkMASH_1.16.library/okf/findings/defects.md`); V1.26 adds
one and fixes none.

## 1. len-2 matches at distance >= 512 are silently dropped

`find` computes `d0 = (dist<<16) | len`, then
`addi.l #0xfe000000,d0` sets the carry exactly when `dist >= 0x200`,
and the caller's `bcs` treats the candidate as no-match.  The stream
stays valid — the token would have been corrupt (`00` prefix polluted
by dist bits 9-10) — but the packer just refuses the match, hurting
ratio.  Faithful in both versions.

## 2. Chain table left uninitialised (V1.26 regression)

V1.16 `filldown`s the whole 64KB chain with 0xffff.  V1.26 writes only
`chain[in.w] = 0xffff` and keeps the rest of AllocMem's garbage.
Early positions walk chains of stale u16 deltas; walks can take far
longer and can yield *pseudo-matches* in memory that was never input.
In practice the garbage deltas quickly fall below the
`cur-32415` window bound or hit the primed 0xffff, so output stays
correct — but packing time is nondeterministic, and on-pathological
heaps bogus matches can reference below-input garbage (below).

## 3. Match window extends below the input buffer

`bound = cur - 32415` puts early candidates at `in-32k`; the compare
reads bytes before the input buffer and can emit matches whose
distance exceeds the position — the decoder then copies from before
the output buffer.  Deterministically wrong-ish on Amiga (heap
contents), nondeterministic on the host harness.  Faithful.

## 4. Positions keyed by pointer low-word -> wrap & aliasing

`pw = (UWORD)cur` wraps mod 64KB; the chain index `sext16(pw)*2`
aliases positions >=0x8000 into alloc1's lower half, and distances
`cur - cand` are computed mod 64KB against that same low-word basis.
For inputs >64KB two distinct positions share a key and a "match" can
source bytes 64KB away — corrupt output, reproduced faithfully
(big200k-class inputs).  Address-dependence also makes packing
nondeterministic under ASLR.

## 4b. Packer hangs on inputs >64KB (delta-0 self-loop)

When `insert` runs at a position whose low-word equals the value still
stored in `head[h]` — inevitable past 64KB, since heads hold stale
low-words of positions 64KB earlier — it writes `CHAIN[pw] = 0`.
Any later chain walk landing on that entry does `cand -= 0` and spins
forever.  Verified on host: `D0LOOP at cur=132361 cand=131072`
(cand low-word 0, CHAIN[0]=0).  Whether it fires depends on the
hash/seed draw (ASLR-sensitive on host, heap-layout-sensitive on
Amiga); when it doesn't fire the >64KB output is merely corrupt per
defect 4.  The original library has the identical bug — the chain
deltas are genuine 16-bit deltas written by the same insert.

## 5. `filldown` underwrites each work allocation by 0x100

`MOVEM`-based memset counts 256-byte blocks with DBF (+1) — alloc2's
seed pass writes `size+0x100` bytes (0x100 below the buffer), and in
V1.16 alloc1's clear does the same.  Harmless in practice (writes into
the same heap block or slack), faithful.

## 6. Decoder trusts the stream completely

No bounds checks on literal runs, distances, or lengths: a desynced or
crafted stream reads/writes out of both buffers.  The unary walks
(unbounded `bsr dbit` loops) can run off the rclass/lclass tables for
corrupt inputs, and `emit_dist`'s class walk is likewise unbounded
(dist >= 0x7ea0 unreachable in practice — chain aliasing retires
candidates first).  Faithful; the host harness pads buffers.

## 7. `-17` pack bound is tighter than V1.16

`bound = out + inlen - 10` (was -50): incompressible inputs now need
only 10 bytes of headroom before pack aborts, and short inputs
(< ~11 bytes) can't pack at all.  Not a bug, but observable:
borderline inputs that failed under 1.16 pack under 1.26.
