---
type: Finding
title: V4.1 defects and inconsistencies
---
# V4.1 defects and inconsistencies

## ByteByte stream tag mismatch (broken default mode)

The encoder emits tag **90** for ByteByte mode
(`moveq #90` -> `moveb d1`), but the decoder's tag
dispatch accepts **100**/67/33 only (`cmpib #100` first).
A ByteByte-packed stream is therefore rejected by the
library's own unpacker with -12.

Confirmed cross-version: V3.1's encoder emits tag 100 for
the same 1-byte-count path and its decoder checks 100 —
the V4.1 rewrite switched the encoder to the
mode-selector values (33/67/90) while the decoder kept
the old tag bytes.

Impact: xi_DefMode = 90 (ByteByte), so the DEFAULT mode
produces undecodable output; AutoSize also breaks
whenever ByteByte wins the trial. Verified in host tests:
9990 of ~20k mixed-mode packs emit tag 90 and are
correctly rejected.

## Decoder has no output bound and no OutLen write

XpksUnpackChunk performs zero bound checks on the write
cursor and never stores xsp_OutLen; corrupt input
overruns the destination buffer.

## Literal scanner tail over-read

The cmpmb pair-check inside the literal scan reads
srcend[0] when the last possible pair is examined.
Output is identical either way; bounded in the
reconstruction.

## Expansion guard only on data bytes

The -17 check (w >= dst+inlen) runs after each data-byte
write but never around the count-field emitters, so the
count bytes themselves are unbounded.

## Descriptor oddities

- xi_UnpackMsg and xi_PackMsg both point at "Running"
- xi_LongName still reads "FastBytesRunner V4.0" in the
  V4.1 binary
- msg strings are puns on the name: "Running" / "Ready" /
  "Steady"
- xi_Name is "FastRunner" while xi_ID is 'FBR2'
- xi_MaxPkInChunk = 0x7fffffff (no real limit)
