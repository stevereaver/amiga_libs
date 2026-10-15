# findings / defects

## 1. Tail overread: lazy probes run past the input end (shipped)

When an item starts with `remaining <= 2` and the lazy budget is
>= 2 (shipped "oblivion" mode 100 -> budget 3; also any nonstandard
xsp_Mode >= 76), the probe loop decrements `remaining` to
0xffffffff (unsigned long wrap).  The match search's
`cmpi.l #3,d7; bcc` guard is UNSIGNED, so the wrapped value passes
and the search reads up to `maxlen=258` bytes past the input
buffer, hashing bytes that belong to the heap.

Consequences depend on the slack contents:
- if the past-end bytes happen to match an earlier position for
  >=3 bytes, a bogus match is adopted and the emitted stream no
  longer round-trips the caller's buffer (decoder output differs);
- the chain walk can also land on garbage pointers (chain[] is
  never initialised -- a slot first read before any insert can
  hold anything);
- worst case is a wild read / crash on Amiga.

This is original behavior, reproduced faithfully in the C.  The
host harness pads the input tail with deterministic junk to
emulate AllocMem slack; with padding, all 5000 round-trips pass.

## 2. Insert reads 2 bytes past the input end (shipped, by design)

LAB_0029 checks `remaining >= 3` once, then chains ALL `len`
positions of a match.  A match whose tail covers the last 1-2
input bytes hashes `cur[0..2]` on up to 2 bytes past the buffer.
Harmless on Amiga (allocation slack) but an out-of-bounds read.

## 3. Decoder is fully unchecked (shipped)

No bounds checks on src or dst; a corrupt stream walks dst forward
out of the caller's buffer (or, before this reconstruction's fix,
a distance > 32 KB misread as SHORT would have gone forward --
the original's `0xffffWWWW` seeding makes ALL tokens backward, and
that is what the C now does).

## 4. Chain entries can be stale garbage pointers (shipped, benign)

chain[] is never reset; a slot is only defined after its position
is inserted.  The newest-first walk exits on the signed distance
bound before following most stale entries, but a garbage entry
pointing forward of `cur` yields a negative `cur-cand`, passes the
bge, and gets byte-compared -- reads through a wild pointer.
Faithful to the original.

## 5. xsp_OutBufLen ignored (shipped, family-wide)

The output bound is `outbuf + xsp_InLen` like every other
Froehling sublib; the advertised output buffer size field is never
read.  Incompressible input returns -17.
