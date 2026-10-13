# xpkTDCS 1.2 — shipped defects & quirks

1. **Realloc copy overruns both blocks.** The grow/shrink copy
   loop counts `used*4` down by 4 but copies TWO longs per
   iteration — 2*used longs total, overrunning both the old and
   new pooled blocks.  Whatever the adjacent pooled allocation
   holds gets scribbled over (deterministic under a bump
   allocator — the corrupted "positions" later surface as
   bogus candidates; the shipped `txt` stream's dist -45 token
   is produced by exactly such a garbage entry).  Reproduced
   verbatim.

2. **259-entry trim corrupts the block.** When a bucket reaches
   used≥259, insert tests `cur - blk[used-259] == 259` (fires on
   dense single-key inserts once the array is deep).  On a hit it
   `used--` then copies 516 longs down by one (1032 bytes counted
   -4 at a time, two movels per decrement) — clobbering blk[0]
   (the used count) with a position pointer and overrunning the
   block.  Reproduced verbatim.

3. **Tier bounds wider than the wire fields.** Emit picks tier
   01 when dist ≥ -16385 but (s16)(tok<<2)|len only encodes
   [-8192,8191]; tier 10 when ≥ -4097 but the field holds
   [-2048,2047]; tier 11's word field is signed16 while find's
   window reaches -65535.  Out-of-range distances wrap into
   positive/forward tokens → corrupt decode (the decoder reads
   distances signed via `moveq #-1` + `movew`, so in-range
   streams are fine; only OOB distances break).

4. **Maxlen clamp aliases `remaining`.** The emit clamp reads
   sp@(150) — the LOW WORD of the `remaining` counter at
   sp@(148) — so `if (len >= (SHORT)remaining) len = rem`.
   Not a bug per se (it bounds matches to input left), but a
   fragile aliasing of an unrelated slot.

5. **Decoder is unchecked.** No output bound, no input bound,
   no OutLen writeback, zero-word test only on the flag-11 path.
   Flag long 0 fast path copies exactly 16 bytes via four
   movels then re-reads flags.

6. **`pos[0]` IS compared** — the candidate walk covers
   blk[used-1]..blk[0]; an earlier reading of the loop exit
   suggested the oldest candidate was skipped.  (Corrected
   during oracle verification.)

7. **machine68k oracle artifact (not a library defect).**
   The emulator's `bcc`/`bhis` does not take the equality case.
   The original's overrun check `cmpal outend,out; bhis` thus
   behaves as `>` under the oracle and emits one more literal
   before -17 than `>=` would — on real hardware it fires at
   equality.  The reconstruction keeps `>=` (true to the
   shipped code); the residual oracle diff is one extra
   AllocPooled(16) on the lit16/allb -17 paths only.

8. **InitStruct datatab is byte-serial.** Commands are
   `a0 off byte pad` / `90 off word` / `80 off long` / `00`,
   packed at arbitrary byte offsets — a word-aligned reader
   misparses it.
