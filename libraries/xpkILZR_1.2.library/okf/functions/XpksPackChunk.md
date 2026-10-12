---
type: Function
title: XpksPackChunk (LVO -36)
---

# XpksPackChunk — xpkILZR 1.2

`a0 = xsp`, `a6 = libbase`.  60-byte stack frame.
Private fields accessed via `a4 = base+0x3c` (a6 is
repurposed as the chain-table pointer mid-function).

## Workmem (first call only, `xsp_Sub[0]` is the flag)

1. `suballoc(0x10000)` → head[0x8000] words → `xsp_Sub[1]`
2. `suballoc(0x8024)` → chain, word-indexed by position
   → `xsp_Sub[0]`, and becomes `a6`
3. fail → `-7` (first block leaks if second fails)

## Preamble

- `head[]` cleared byte-wise, **65536 iterations**
- output cursor = `xsp_OutBuf`; bound = `OutBuf+OutBufLen`;
  first flag byte pre-zeroed
- 16-bit InLen emitted MSB-first (same bit writer)
- `w = 8`, width-threshold `a0 = in+256`, `best = 0`,
  `bpos = 0`, `hash = 0`, `atend = 0`

## Initial scan (LAB_0036)

Walk `scan` from inbuf; each step: set `atend` when
`scan >= inend`, then `cnt++, scan++`; exit on `cnt > 18`
or `atend`.  `runcap = cnt - 2` (= min(17, InLen)).
`runcap > 1` → seed `hash = (in[1]<<5 ^ in[2]) & 0x7fff`
(OOB for InLen ≤ 2).

## Emit (LAB_0039)

- `best = min(best, runcap)` — mid-stream runcap = 17, so
  emitted match lengths cap at **17** (len-3 field only
  ever carries 0..14)
- `best < 3` → literal: flag `1` + byte, `d3 = 1`
- else → match: width bump if `a2 > in+2^w` (once);
  flag `0`; `pos:bpos(w)`; `len-3(4)`; `d3 = best`

Bit writer: `or.b mask,(w)` for set bits; `mask >>= 1`;
on wrap `w++`, `w >= outend` → `-17`, else `*w = 0`.

## Insert (LAB_004A..004E) — `d3` positions

Per position: `if atend: runcap--` else advance `scan`
(set `atend` when it reaches `inend`); then `a2++`, roll
`hash = (hash<<5 ^ a2[2]) & 0x7fff`, `pos = a2-in`,
`d4 = head[h]; head[h] = pos; chain[pos] = d4`.
`d4` after the set = last insert's old head = first
candidate; `96(sp) = d4`.

## Finder (LAB_0056)

`d3` walks `chain[]`; requires `d4 >= d3` (monotonic).
Candidate eval (LAB_004F): precheck `in[cand+best]` vs
cached `in[cur+best]`; then `cmpm` byte0/byte1; then an
8-per-group byte scan bounded by `cur+18`.  Mismatch →
`fail++`, budget 17.  Better len → `best`, `bpos = cand`,
refresh prebyte `in[cur+len]`; `len == 18` → emit now.
Scanner restores `a2 = lim-18` unconditionally.
`runcap == 0` at LAB_0057 → done; `OutLen = w-out+1`.

Tail budget math: `atend` trips at insert `n-17`, drains
17 → consumed `= InLen` exactly — nothing is dropped.
