# xpkSQSH 1.2 (020) — defects & inconsistencies

1. **Output budget = inlen**: emit bails with -7 (-> -17 to the
   caller) once `bitpos >= inlen*8`; the library cannot expand data
   at all. Small or incompressible inputs always fail — observed on
   18/77 sweep cases including an 8 KB sine whose byte pattern never
   repeats.
2. **Match lookahead reads past in+inlen**: the `cmpm.b` candidate
   compare runs up to 46 bytes past the input end; on the last
   positions a "match" can be fabricated from trailing garbage and
   emitted with a length exceeding the remaining input (the decoder
   then overruns the output buffer the same way — first byte still
   lands correctly).
3. **Literal run overshoot at the last token**: a narrow-width
   literal token always emits its full run (5 deltas) even when fewer
   positions remain; trailing deltas are read from memory past
   in+inlen and the decoder likewise writes past `out+inLen` before
   the loop check stops it.
4. **Decoder trusts the stream entirely**: no bounds checks on
   bitpos, match distance, or output position — a corrupt stream can
   read/write arbitrarily (the `00`-class distance prefix bug in my
   first reconstruction demonstrated how quickly this desyncs).
5. **Descriptor PackMem (0x2080) vs actual alloc (0x22080)**: the
   advertised pack memory covers only the match-node area; the real
   allocation adds the 0x2000-byte hash-head table at offset 0.
   Probably deliberate (the 0x2000 is part of the node arena in the
   author's accounting) but the two numbers disagree.
6. **`xsp_Sub[0]` stale after free**: -42/-60 free the work buffer
   but don't NULL the pointer; a second pack call on the same xsp
   would reuse a freed pointer (same pattern as the HFMN siblings).
7. **-24 quirk**: the reserved vector lands on the entry stub via the
   functab, `moveq #0,d0;rts` — harmless.
8. **rt_EndSkip = 0**: RomTag EndSkip points at hunk+0 (same as
   siblings).
9. **lenextra/lentab entry 0-1 are zeros**: lens 0/1 are unreachable
   (matches only emit len >= 2); the zero entries exist only as table
   padding.
10. **68020 gate**: LibInit refuses non-020 CPUs; the original relies
    on 020 bitfield semantics (`bfffo d1{24:7}` for width select,
    `bfins`/`bfextu`-style bit IO). The reconstruction expresses these
    in portable C — same semantics, different instructions.
