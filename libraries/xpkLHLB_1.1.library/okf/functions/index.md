# Functions

| LVO | Symbol | Role |
|-----|--------|------|
| -6  | LibOpen | clear DELEXP, openCnt++, return base |
| -12 | LibClose | openCnt-- (skipped when already 0); expunge when 0 + DELEXP |
| -18 | LibExpunge | set DELEXP first; CloseLibrary(lhbase); Remove + FreeMem |
| -24 | LibNull | moveq #0,d0/rts stub (hunk+6) |
| -30 | XpksPackerInfo | `move.l #xpkinfo,d0` -- immediate, code hunk |
| -36 | XpksPackChunk | allocate lh block + scratch, delegate to lh -42 |
| -42 | XpksPackFree | shared free routine (scratch FreeMem + lh -36) |
| -48 | XpksPackReset | stub (hunk+6) |
| -54 | XpksUnpackChunk | allocate lh block, delegate to lh -48 |
| -60 | XpksUnpackFree | same shared free routine as -42 |

- Module entry (hunk+0) is `moveq #-1,d0; rts`.
- Absolute-longword functab, 10 entries + -1.
- LibClose tests openCnt *before* decrementing, so a Close on a
  zero count still evaluates the deferred-expunge check.
- LibExpunge sets LIBF_DELEXP unconditionally *before* the count
  test -- slightly different from the test-then-set convention.

- [XpksPackChunk.md](XpksPackChunk.md)
- [XpksUnpackChunk.md](XpksUnpackChunk.md)
