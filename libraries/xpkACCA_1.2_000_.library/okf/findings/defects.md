# xpkACCA 1.2 — defects & quirks (all preserved)

1. **PackReset clears DOWNWARD and past the buffer start.**
   Clear starts at Sub0+0x4000 (turbo) or Sub0+0x40000 (crawling)
   and walks DOWN in 160-byte chunks (1 long + 3x13-long moveml),
   105 inner iterations x (Sub1+1) passes, with a6 CONTINUING to
   descend across passes.
   - turbo (1 pass = 16800B): [Sub0-0x1a0, Sub0+0x4000) — the whole
     table plus the stored alloc-size long at Sub0-4 and ~412 bytes
     below the allocation -> PackFree later calls FreeMem(ptr,0).
   - crawling (16 passes = 268800B): [Sub0-0x1a00, Sub0+0x40000) —
     the whole 256KB hash table plus ~6.6KB below the buffer — but
     the 32KB ring table at +0x40000 is NEVER cleared -> garbage
     chain entries -> nondeterministic candidates / wild reads.

2. **One-time workmem, wrong-mode reuse.** xsp_Sub0 is allocated
   on the first pack call and never re-checked. Calling crawling
   after turbo reuses the small 16KB buffer with the 288KB packer
   -> heap smash. Calling turbo after crawling clears only the
     big-mode region and leaves turbo's head table uncleared.

3. **PackFree leaves xsp_Sub0 dangling** (no write-back of 0):
   a second PackFree double-frees; a pack after free reuses a
   freed workmem.

4. **crawling run-18 encodes wrongly.** The run path emits class-1
   tokens with N = R-19; for R=18, N=-1 -> byte1 `0x1f`, byte2
   `0xff` (lsr4 of 0xffff), which decodes as a run of 15+16*255+19
   = 4114 bytes. Host test: 18 identical bytes decode to 4114.

5. **turbo len-2 matches emit a class-2 token.** `(len<<4)|dm3lo`
   for len=2 lands on class 2 = "common pair" — the decoder emits
   `table16[dm3&15]` twice and consumes ONE byte where the packer
   wrote TWO -> the entire stream desyncs (verified: 'abab..'
   round-trip corrupts at offset 2 and everything after).

6. **turbo accepts dist<3 matches** (no lower bound on dist-3):
   a len-2+ match at dist 1..2 emits dm3 = -2/-1 -> decodes to dist
   4097/4098 -> reads before the output buffer.

7. **crawling class-2 emit is dead code** (0x464..0x47e): best len
   floors at 2, so a run of exactly 2 never reaches the pair emit
   — `bhis 0x4b4` (match) / `bcss 0x4ba` (literal) covers all.

8. **Decoder reads the flag word before the in-end check** —
   always reads 2 bytes past InBuf+InLen (then compares).

9. **Decoder match/byte-run paths have no output bound checks** —
   corrupt streams can overrun OutBuf arbitrarily.

10. **UnpackChunk writes the produced length at xsp+12**
    (OutBufLen field), NOT xsp_OutLen (+16) — the caller-visible
    out length lands in the input-side field.

11. **crawling bound ignores OutBufLen**: `out+InLen` is the emit
    limit — the packer can write up to InLen bytes regardless of
    the caller's buffer size.

12. **turbo reads a4[2] when only 2 bytes remain** (match-try at
    `remaining-2 >= 0`) — reads one byte past in_end.

13. **turbo loop-end test is `a1 > a3` (strict)**: an input that
    ends exactly on the boundary emits/reads one byte past in_end.

14. **Len cap off-by-one at exhaust (turbo):** the match-length
    dbcs loop sets d7=0 after count exhaustion, reporting len=269
    even though 268 extension compares succeeded (cap semantics —
    cosmetic).

15. **Stream header is cold**: flag word at stream+0 — a packed
    buffer always starts with 2 flag bytes, even for pure literal
    runs; empty input packs to a flag word + nothing (OutLen=2).
