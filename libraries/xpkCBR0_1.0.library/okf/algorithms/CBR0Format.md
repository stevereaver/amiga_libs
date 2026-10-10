---
type: Algorithm
title: CBR0 stream format
---
# CBR0 stream format

Header-driven byte stream, no terminator; decoding stops
when the input is exhausted.

- `h < 0x80`  — literal run: copy h+1 bytes (1..128)
- `h >= 0x80` — repeat run: copy next byte 257-h times
                (2..128; max run emitted is 128 -> h=0x81)

## Encoder segmentation (XpksPackChunk)

- Two equal bytes at the segment start open a repeat run,
  emitted in <=128-byte pieces; a run of 2 is emitted even
  mid-stream.
- Otherwise a literal stretch of <=128 bytes is gathered,
  ending before the next equal pair; the header stores
  n-1.
- A single leftover input byte emits a literal-1
  (`0x00 <byte>`).

## Bounds / error codes

- `-11` — pack input > 0xfffc; unpack input >= 0xfffc
  (asymmetric!)
- `-17` — output would reach `dst + insize` (expansion
  guard); the check precedes each write
- `-10` — output would pass `dst + 0x100 + OutBufLen`
  (256-byte slack over the nominal buffer bound)

The decoder checks `dst + 0x100 + OutBufLen` before every
emitted byte; corrupt or truncated input overreads the
source buffer.
