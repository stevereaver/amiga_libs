# xpkHUFF 0.62 — shipped defects and quirks

All reproduced verbatim in `source/xpkhuff.c` /
`source/xpkhuff_lib.s`.

## Bugs

1. **16-bit word counters everywhere.** Histogram, bit emit,
   scramble and descramble loops are `dbf` counters seeded
   from `count-1` (the scramble/descramble use `subq.w`):
   inputs > 65536 process only `(count & 0xffff)` items.
   `inlen=65537` packs exactly ONE symbol (verified:
   outlen=264). 80000 bytes pack 10304. The resulting stream
   is emitted without complaint.

2. **u16 histogram counts** wrap for frequencies >= 65536
   (moot given #1, but faithful).

3. **Unbounded unpack tail.** After the byte-bounded first
   decode loop, the tail emits `expected-produced` more
   symbols; the bit walk is not bounded by input length and
   output length is never checked — reads past the input
   buffer, writes past `outbuf+expected`. If produced >
   expected the word counter wraps to ~65k garbage emits.

4. **Trie arena overflow.** The unpacker reserves 510 node
   slots + root (511 nodes); a full 256-leaf tree needs 512.
   The 511th node overflows 10 bytes into the descramble
   buffer at workmem+5148 — live on password streams where
   the buffer is in use.

5. **pwhash 0xC0 contamination.** The per-byte `move.b` into
   `d1` leaves 0xC0 in the high byte (seed 0xC0DE): every
   password character adds/xors 0xC0xx, not the plain byte.
   Empty password hashes to 0xCAFEABAD.

## Quirks (not necessarily bugs)

- Budget is `outbuf+inlen`, so only streams that beat raw
  size succeed; error is -10 (pw set) or -17 (pw NULL).
- `xsp+12` is only sanity-checked `>6`, never bounds output.
- Budget error code depends on whether `xsp_Password` is
  non-NULL, not on whether a password is in use.
- `rt_IdString` skips the `$VER: ` prefix (points at
  "xpkHUFF.library ..." 6 bytes into the version string).
- Vestigial `bsr` to a register-neutral nop sub (moveml/nop/
  moveml) inside LibExpunge — dead subresource hook.
- LibInit pushes/pops the full register set TWICE.
- -42/-48/-60 are bare `rts` (d0 passthrough), not zero
  stubs like 0.64.
- Dead data {u32 0, u16 8, u32 0x32e} after the -60 stub.
- Deferred expunge WORKS in this version (bset lands on the
  library flags) — the ExecBase+14 a5/a6 bug only appears in
  the 0.64 rewrite.
- Seglist stored at lib+34 (private field), not a code cell.
- Single-symbol inputs get a pseudo internal root so the
  decoder's walk still works.
- Sorted-list leaf selection keeps the LAST equal-count leaf
  per rescan -> byte-ordered lists for uniform alphabets.
- The unpacker's first decode loop is unrolled to 8 copies of
  the bit-walk body (full-byte unroll).
- Dos entry stub writes a fixed 128 bytes (the message +
  trailing NUL) via dos Write(Output()).
