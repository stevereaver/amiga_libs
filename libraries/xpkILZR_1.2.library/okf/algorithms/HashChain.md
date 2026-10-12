---
type: Algorithm
title: xpkILZR 1.2 hash chains
---

# Hash chain — xpkILZR 1.2

Two tables, allocated per first PackChunk via the pool
sub-allocator:

- `head[0x8000]` words — xsp_Sub[1] (cleared every pack)
- `chain[pos]` words — xsp_Sub[0] (NEVER cleared)

Rolling hash over 3 input bytes:

```
h(p) = (in[p]<<10 ^ in[p+1]<<5 ^ in[p+2]) & 0x7fff
     seeded as (in[1]<<5 ^ in[2]) then rolled with in[a2+2]
```

Insert per consumed position `p` (cursor advances BEFORE
the insert — positions cur+1..cur+len go in, plus the new
cursor itself):

```
old = head[h]; head[h] = p; chain[p] = old
```

Finder: `cand = old` (first candidate = last insert's
previous head); walk `cand = chain[cand]` while
`prev >= cand` (monotonic positions) and `cand != 0`.

Candidate eval:

1. precheck `in[cand+best] == in[cur+best]` (fail → budget)
2. `cmpm` bytes 0,1 (fail → budget)
3. byte scan in groups of 8, bounded by `cur+18`
4. `len > best` → update best/bpos, refresh prebyte,
   `len == 18` → early emit
5. `fail > 17` → stop (18 rejected candidates max)

Emitted `pos` = `bpos` — the ABSOLUTE candidate position.
