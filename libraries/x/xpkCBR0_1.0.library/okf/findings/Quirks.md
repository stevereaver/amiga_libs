---
type: Finding
title: V1.0 quirks and inconsistencies
---
# V1.0 quirks and inconsistencies

## lib_Flags bit-numbering quirk (LIBF_SUMMING as DELEXP)

LibOpen/LibClose/LibExpunge use `bclr/bset/btst #8,lib_Flags`.
Bit ops on a memory operand are byte-wide, so the bit number
wraps modulo 8: bit 8 -> bit 0 = **LIBF_SUMMING**, not bit 3
(LIBF_DELEXP).  The library remains self-consistent
(expunge-while-open sets bit 0, close tests bit 0), but it
does not use the flag the OS itself manages.

V1.1 fixed this to `andib #-9` / `btst #3` / `orib #8`
(LIBF_DELEXP).  Reconstruction reproduces the V1.0 bit-0
semantics.

## Tail over-read in the literal scanner

The literal loop's run test (`cmpb src[1],cur`) reads
`srcend[0]` when the last input byte is examined.  Harmless
to the emitted stream (the byte only steers the last input
byte between the literal and the literal-1 emit path, which
produce identical output) but a genuine out-of-bounds read.
Reconstruction bounds the peek.

## Asymmetric input-length limits

Pack rejects `insize > 0xfffc` (accepts exactly 0xfffc);
unpack rejects `insize >= 0xfffc`.  A 0xfffc-byte chunk can
be packed but its stream (if it ever reached that length)
would be rejected on decode.

## Dead code / dead data

- The -17 error path `jsr`s a bare `rts` (LVO -48 slot)
  before returning — a dead call.
- A helper at hunk+0x404 is `moveml save; moveml restore;
  rts` — a pure no-op.
- String "V1.0 (23-Aug-1992)" (hunk+0xb0) is unreferenced;
  lib_IdString is the bare word "xpkCBR0" (no version) in
  both the RomTag and the datatab.
- `$VER:` uses 0xa0 (NBSP) separators between fields.

## Descriptor oddities

- xm_ChunkSize = 63 (0x3f) — an odd default chunk size.
- xi_DefMode = 50 although xm_Upto = 100.
- Descriptors live in the base, filled by LibInit field by
  field (no static descriptor block in the file).
