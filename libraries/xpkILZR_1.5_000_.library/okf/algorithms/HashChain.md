---
type: Algorithm
title: ILZR hash-chain search
---

# Hash chain

Rolling hash over three bytes: `h = ((h<<5) ^ in[p+2]) & 0x7fff`.
Seeded unconditionally with `(in[0]<<5 ^ in[1])&0x7fff` —
for InLen<2 that reads past the buffer (value unused on
the tail path, but read).

Tables in the 256KB workmem:

- `head[0x8000]` (words) at workmem+0 — latest position per hash
- `chain[0x4000]` (words) at workmem+0x10000 — previous position
  with the same hash

## Deferred insertion

Each loop head inserts the positions the last item consumed
plus the new current position — `plen` iterations of

```
p++; h = (h<<5 ^ in[p+2]) & 0x7fff;
chain[p] = head[h]; head[h] = p;
```

The original reaches the loop through the `dbf` itself, so
the body runs exactly `plen` times (not plen-1).  Because a
match consumes `len` positions but only inserts them at the
NEXT head, the tables always describe the consumed prefix.

head[] zero-init means position 0 reads as "empty" — it can
never be a candidate, so no match can source offset 0.

## Candidate walk

```
best = 2
for cand = chain[cur]; cand; cand = chain[cand]:
    if in[cur+best] != in[cand+best]: continue   # precheck
    l = 0; while l<18 and in[cand+l]==in[cur+l]: l++
    if l > rem: l = rem
    if l > best: best=l; bpos=cand; if best==18: break
emit match(bpos,best) if best>=3 else literal
```

The precheck reads `in[cur+best]` — for `cur+best` near the
end it reads past InLen (harmless, value only prunes).  The
18-cap is the unrolled-cmpm maximum; a 18-byte match is
accepted immediately without walking the rest of the chain.

## Latent overflow

`chain[]` is only 0x4000 words (16KB).  For InLen > 0x4000
the insert writes `chain[pos]` past the workmem block —
MaxPkInChunk=0x4000 is the only thing preventing heap
corruption.  Latent defect, masked by the descriptor cap.
