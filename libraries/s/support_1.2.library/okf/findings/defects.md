# support.library 1.2 — defects & quirks (all reproduced)

1. **Version inconsistency**: the datatab sets lib_Version=3 /
   lib_Revision=4 while the RomTag says version 1 and the id string
   says "1.2".  The library reports itself as 3.4 at runtime.
2. **lib_IdString never set**: datatab has no entry for lib+24, so the
   field stays 0 even though rt_IdString points at a valid string.
3. **Dead banner routine at code+0**: 54 bytes of OpenLibrary/Output/
   Write code that nothing calls; also pulls the dos.library name to
   +0x130.  Banner says "(13.03.)" while the idstr says "(11 Januar 96)".
4. **-24 is a real routine**, `moveq #0,d0; rts` — not a NULL/0 vector
   entry (still callable, returns 0).
5. **-30 SnapSize oddities**:
   - `*ctr` is re-based to `0x40020050` (mode 3) / `0x40020020` (other
     modes) at the top of EVERY pass (including repicks), then bumped
     once per failed ladder test — callers receive a magic|index code,
     not a clean index, and a repick silently resets it.
   - mode 3 + flag != 0x200000 rewrites the LOW WORDS of *op/*oh to
     600x480 after every pass, then the clamp raises them back to the
     requested size — net effect is `*op = max(600..picked, w)`;
     harmless in practice but the intermediate values are wrong.
   - mode-3 ladder skips the 800x600 test entirely: after failing
     768x576 it sets 800x600 unconditionally (no <= test).
   - the second-pair fit path re-classifies into a single scratch
     long at code+0x700 with both pointers equal — the h-pick
     overwrites the w-pick, leaving only the height.
   - repick compares are 16-bit (`sub.w`) on 32-bit results.
6. **Clear routines write longs with word-ish strides** — Keep0/Keep2
   use `movel #0,(a0)+` + `subq.l#2` (write 4, advance counted 2), so
   each pass stores 2*rowlen bytes; correct only because rows 1+2 of a
   triple are contiguous.  All loops are do-while: total<=0 or
   rowlen 0 still writes at least one long past/at the buffer.
7. **-60 Invert hangs on n=0** — `subq.l#1; bne` wraps to -1 and runs
   ~4 billion iterations.
8. **-66 Gray is not a true mean** — each channel byte is divided by 3
   separately then summed (truncating 3x), and the row-triple counter
   is tested inside the column loop so the final triple processes one
   column too many (clobbering up to 3 bytes past the last column
   position within the buffer layout).
9. **-90 Mirror drifts on odd widths** — row advance is
   `+width + width/2` (back) / `+width/2` (front) = 2*(w/2), one byte
   short of w when w is odd, so subsequent rows mirror off-by-one.
10. **-102 Mosaic calls mathffp through a4 without opening it** —
    callers must supply mathffp.library base in a4; a4=0 calls into
    low memory.  Remainder columns (w%10) are skipped but remainder
    rows (h%10) are entirely unprocessed; d2/d5 are 16-bit DBF
    counters so w/10 or h/10 of 0x10000 wraps.
11. **-108 Transpose writes dst/src/w/h into scratch** (code+0x700)
    that is never read back — dead bookkeeping, shared with -30/-102.
12. **Expunge is not re-entrant-safe vs Close**: Close at OpenCnt 0
    with the deferred flag runs Expunge inline; calling Expunge again
    afterwards re-removes and re-frees the library (double-expunge —
    callers must not do it, verified in oracle).
