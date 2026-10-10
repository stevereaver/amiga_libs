---
type: Finding
title: V3.1 defects and inconsistencies
---
# V3.1 defects and inconsistencies

## Windowed scanner emits out-of-bounds input (W/B modes)

The WordByte (window 32767) and ByteByte (window 127)
scanners always run the first pass over a full window of
positions.  For inputs smaller than the window the match
loop reads past `InBuf+InLen` and whatever bytes follow
in memory are compressed into run items and emitted.

Example (host run, input `ABCDEFGHIJ` + 0x55 fill,
WordByte): `43 fff7 <10 literals> 03dd 55` — a run of
990 bytes of post-buffer memory appended to the 10-byte
payload.  The stream decodes fine but the output is
larger than the input and contains foreign memory.

Practical impact: **any** WordByte pack of < 32 KB input
and **any** ByteByte pack of < 128 byte input leaks
memory into the compressed stream.  These are the
advertised "fast" modes for small/medium data.

## Tail byte drop (W/B modes)

When the last input byte is the terminator of a
qualifying run (i.e. `...X{n>=minr}Y`), the consumed
counter reaches `inlen-1` when the run emits and the
loop exits before Y seeds an item.  Decoded output is
input minus the final byte.  Reproduced: 47 cases in
host testing.

## Empty-input emits a 1-byte run (all modes)

The seed read `d3 = *a1` is unconditional.  InLen 0
emits `<tag> <count 0> <inbuf[0]>` — a 1-byte run of
whatever precedes/follows the empty buffer.

## Unpacker has no safety rails

- No output bound check; corrupt counts overwrite any
  amount of memory past OutBuf.
- Never writes `xsp_OutLen`.
- Loop guard `src < inbuf+inlen-1` means a count field
  beginning at the very last stream byte is skipped —
  and a 4-byte count read near the end can overread up
  to 3 bytes past the input.
- `xsp_InLen` of 0 makes `end < src`; loops skip, but
  the tag byte is still read unconditionally.

## Mode dispatch is byte-wide

`cmpb` on xsp_Mode's low byte only: modes 0..33 ->
LongByte, 34..67 -> WordByte, 68..255 -> ByteByte.
E.g. xsp_Mode 0x121 (289) packs LongByte.

## Descriptor oddities

- "Autosizing" mode (list head, upto 0, packspeed 1,
  ratio 0) selects LongByte — there is no AutoSize pass
  in 3.1.
- xi_UnpackMsg == xi_PackMsg ("Running" twice).
- xi_Name "FastByteRun" vs lib name FBR2 "FastBytesRunner".
- "better then" typo in xi_Description.
- Entry stub returns -1 (V4.x returns 0).

## Cross-version note

V3.1's three tags (33/67/100) are self-consistent; the
V4.1 rewrite regressed ByteByte to emit selector 90,
which its own decoder rejects — V3.1 is the last
internally-consistent ByteByte implementation.
