# Defects & quirks — xpkMASH 2.0(000)

All reproduced in the reconstruction unless noted.
Verified against the original binary running under a
Musashi m68k oracle (`work/oracle*.py`).

## 1. Uninitialized final flag-slot byte (observed)

The emitter reserves a byte slot for the pending flag
group and backfills it when 8 bits accumulate.  The
stream's final partial group never reaches 8 bits, so the
LAST output byte is whatever was in the output buffer —
heap garbage on a real Amiga.  Packed streams compare
byte-identical to the original modulo this last byte.
Confirmed empirically: re-running the original with a
fresh buffer produces different tail bytes.

## 2. Unbounded `cmpmb` reads past InBuf (observed)

The match compare has no end-of-input check: on uniform/
repetitive data it scans past InBuf into adjacent memory
until it hits a nonzero byte — traced ~2MB of reads past
a 4000-byte input (the work-buffer size header finally
stops it).  Recorded match lengths therefore depend on
heap contents.  The reconstruction matches this (host
harness writes a 0x55 sentinel at in[n] for deterministic
tests).

## 3. PackFree leaves a dangling xsp_Work (UAF)

LVO -42 does `FreeMem(xsp_Work, xsp_WorkSize)` but never
clears the pointer.  A subsequent PackChunk reuses the
freed buffer — use-after-free.  Faithful in C.

## 4. No size check on workbuf reuse

`xsp_Work != NULL` skips allocation entirely — no inlen
tracking.  Packing a larger input with a cached workbuf
overflows the gap array (sized `2*first_inlen`) and walks
stale gaps.  Observed on the original under sequential
packs: 1MB of garbage output, `-17` rejects, and a wild
write to `0xfffffffe`.  Same class of UB in the
reconstruction (different heap -> different garbage).

## 5. Record stream overlaps the live gap table

Pass2 writes records at wk+0 while gaps[] (wk+0x20000)
is still being read.  For inlen > ~43690 (record stream
> 0x20000 bytes, possible since MaxPkInChunk = 64K) the
records corrupt unread gaps -> bogus matches.
Faithful.

## 6. Literal runs >= 32776 hang the packer

`emit_gamma` for run-8+ uses a 16-bit span register; a
gap >= 32776 wraps it to 0 -> the bit loop never
terminates.  Inputs with that long a literal run hang
the original outright.

## 7. len-2 matches with dist >= 512 are silently dropped

The '00' token only carries a 9-bit distance; the packer
checks `dist < 512` in two places (main emit + the tail2
path) and falls back to a literal instead.  Same defect
class as V1.16's polluted-prefix bug, handled more
defensively here.

## 8. Pack bound `OutBuf + InLen - 10`, and inlen <= 10

Output must beat the input by >= 11 bytes or PackChunk
returns -17.  For inlen <= 10 the bound pointer
underflows/sits at-or-before OutBuf — pack always fails;
the intermediate-record check also lets full streams
emit before failing.

## 9. Decoder: zero flag byte inside distance gamma loses bits

When the bit accumulator consumes a `0x00` flag byte in
the middle of a distance gamma, its trailing zero bits
are dropped (the acc-reload path misses the +1 sentinel
when X is clear) — the stream desyncs by those bits.

## 10. Decoder: distance-0 match reads unwritten output

A malformed stream can select distance 0 -> the copy
reads `out[pos-0]` = the byte being written, i.e.
propagates stale/unwritten output bytes (observed:
copies zeros).

## 11. Decoder: end-marker overconsumption

The final '00' end marker can make the decoder read bits
past the packed stream end and write up to 2 bytes past
the output buffer end.

## 12. reloc[0] corrupts the entry stub at load

The first HUNK_RELOC32 entry patches code+0 — the
`moveq #0,d0` of the entry stub — so on a real load the
stub becomes `moveq #base_hi,d0` garbage.  The reserved
vectors -24/-48/-60 all point at it: after loading,
calling them executes corrupted code.  AmigaDOS relocates
only the file's 32-bit words; offset 0 holds part of the
stub's operand, which is patched anyway.  The rebuild
drops this relocation (stub stays functional).

## 13. pass1 reads 1 byte past InBuf for even inlen

The gap pass always consumes `1 + 2*pairs` bytes; for
even inlen that reads `in[inlen]`.  Reproduced — the host
harness allocates a pad byte.

## Oracle notes

Two anomalous results traced to heap state, not logic:
- `period5`-style inputs produced a corrupt stream in a
  dirty-memory run (own decoder failed) but pack fine on
  clean memory — unbounded-compare + garbage-gap fallout.
- a traced wild write to `0xfffffffe` on one mixed input
  in batch mode — same class (dirty gap-chain walk).
