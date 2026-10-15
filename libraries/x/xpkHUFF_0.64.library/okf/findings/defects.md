# xpkHUFF 0.64 — shipped defects and quirks

All reproduced verbatim in `source/xpkHUFF.c`.

## Bugs

1. **Deferred expunge is dead.** `LibExpunge` reloads `a6`
   with SysBase *before* the flag write, so
   `bset #3,14(a6)` lands on **ExecBase+14**, not
   `lib->lib_Flags`. `LibClose` at opencnt==0 checks the
   library flag (never set) and returns 0 — an opened library
   can never be expunged by OpenCnt reaching 0. Verified:
   original flags stay 6, no Remove/FreeMem on Close.

2. **16-bit word counters everywhere.** Histogram, bit emit,
   scramble and descramble loops are `dbf` counters seeded
   from `count-1` (the scramble/descramble use `subq.w`):
   inputs > 65536 process only `(count & 0xffff)` items.
   `inlen=65537` packs exactly ONE symbol (verified:
   outlen=264).  `inlen=80000` packs 14464 symbols. The
   resulting stream is emitted without complaint.

3. **u16 histogram counts** wrap for frequencies >= 65536
   (moot given #2, but faithful).

4. **Unbounded unpack tail.** After the byte-bounded first
   decode loop, the tail emits `expected-produced` more
   symbols; the bit walk is not bounded by input length and
   output length is never checked — reads past the input
   buffer, writes past `outbuf+expected`. If produced >
   expected the word counter wraps to ~65k garbage emits.

5. **Trie arena overflow.** The unpacker reserves 510 node
   slots + root (511 nodes); a full 256-leaf tree needs 512.
   The 511th node overflows 10 bytes into the descramble
   buffer at workmem+5148 — live on password streams where
   the buffer is in use.

6. **pwhash 0xC0 contamination.** The per-byte `move.b` into
   `d1` leaves 0xC0 in the high byte (seed 0xC0DE): every
   password character adds/xors 0xC0xx, not the plain byte.
   Empty password hashes to 0xCAFEABAD.

## Quirks (not necessarily bugs)

- Budget is `outbuf+inlen`, so only streams that beat raw
  size succeed; error is -10 (pw set) or -17 (pw NULL).
- `xsp+12` is only sanity-checked `>6`, never bounds output.
- Budget error code depends on whether `xsp_Password` is
  non-NULL, not on whether a password is in use.
- Vestigial `bsr` calls to the null stub in LibInit (x2) and
  LibExpunge (x1) — dead subresource hooks.
- Seglist stored in a code-resident cell (code+0x7a), not
  lib+34.
- Single-symbol inputs get a pseudo internal root so the
  decoder's walk still works.
- Sorted-list leaf selection keeps the LAST equal-count leaf
  per rescan -> byte-ordered lists for uniform alphabets.
