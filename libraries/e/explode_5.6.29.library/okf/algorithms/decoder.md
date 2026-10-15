# explode decoder

A backward-reading LZ + table-driven decoder that inflates a loaded
executable segment in place, then fixes up hunk relocations.

## Source / ring

- `a0` — bit stream source, read **backwards** (`-(a0)`) starting at
  the end of the packed data placed inside hunk[count-2].
- Ring buffer = last hunk's data area: `a6` = top (hunk end),
  `d4` = size. `a2` = read cursor; `a3` = write cursor. Both wrap
  (`a2 -= d4` at top; match source `a5` wraps `+= d4` below bottom and
  `a5 = a2` when it lands exactly on `a6`).
- Decoder is a **coroutine**: every `a2` wrap `bsr`s into `_exp_rewind`
  which decodes until the ring is full (space counter `d5`) or the
  block counter runs out, parks its state (litrun word, bit-buffer
  byte, resume-match byte) into the a4 frame and `rts`es back into the
  caller's copy loop. A pending match resumes mid-copy via frame byte
  +3 (`bne _exp_mxfer` on entry).

## Bit reader

Classic backward stream: `add.b d1,d1` shifts a bit into carry/X;
when d1 empties (`bne` fails) reload `move.b -(a0),d1` then
`addx.b d1,d1` which both shifts and injects the carried bit — giving
an MSB-first stream of exactly 8 bits per byte.

## Symbol coding (per "block"; a4+4 = remaining block count)

First bit:

- `0` -> literal-run header: `d2` literals follow (raw `-(a0)` bytes),
  length derived from the 8-entry mask table built at setup.
- `1` -> match; length by unary-ish prefix:
  `10`=3, `110`=4, `1110`=5, `11110`=raw byte, `11111`=6+3-bit (6-13);
  (the `11...` prefixes chain: each extra `1` descends a level; `0`
  terminates). Exact mapping per the disassembly: bit-path
  0->len2(d7=0), 10->3(d7=1), 110->4(d7=2), 1110->5(d7=3),
  11110->byte len(d7=3), 11111->6+3bits(d7=3). Wait — see below for the
  authoritative cascade.

Authoritative cascade (verified against disasm):

```
bit=0                -> literal run (d7 unused)
bit=1 then:
  next=0 -> len 2, class 0
  10     -> len 3, class 1
  110    -> len 4, class 2
  1110   -> len 5, class 3
  11110  -> len = raw byte, class 3
  11111  -> len = 6 + 3 bits, class 3
```

then distance class bits:

```
next=0     -> dist = 2*d2 + bit          (short, via addx chain)
next=10    -> tab1b[class] bits -> d2, dist += 2
next=11    -> dist = tab1[class] (+4 into table index) + tab1b bits
```

followed by a second stage: 2 selector bits choose bases from
a4+20/a4+28 word tables (length sums / prefix sums built at setup),
then `a4+36+idx` extra-bit count (bit7 set -> whole next byte used),
`dist = accum + base + 1`. Match source `a5 = a3 - dist` with ring
wrap.

## Per-hunk control stream (ring longs via `_exp_rdlong`)

- `bit31` set -> end of this hunk's output; advance `d5`.
- `bit30` set -> relocation list: next long = count, then hunk index;
  each subsequent ring long accumulates `d2` (delta-encoded offsets)
  and `*(a3+d2) += hunkbase` — standard LoadSeg-style RELOC32 fixup
  applied in place.
- else `d0>>1` longs are copied ring -> dest (8-long unrolled loop
  with a 32-byte look-ahead margin, byte-wise tail).

## Tail (`_exp_tail`)

After the last output hunk: `FreeMem`s every loaded hunk beyond the
output limit (index `a4+52` = count-2) and clears the link long of the
last kept hunk, shrinking the segment to the decoded program.

## Header bytes consumed at setup (a5 = ctrl block)

| Ctrl off | Use |
|---------:|-----|
| +0 hi nib | reserved; +0 lo nib selects 12-byte table record |
| +1 | initial bit-buffer byte |
| +2..3 | literal-run length word |
| +4..7 | block counter (sign flag consumed by setup) |
| +9 | flag byte OR'd into the hunk[count-2] size (stream size LSBs) |
