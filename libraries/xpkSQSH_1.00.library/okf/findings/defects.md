# xpkSQSH 1.00 — defects & inconsistencies

1. **Output budget = inlen**: pack bails with -7 -> -17 once
   `bitpos >= inlen*8`; cannot expand data at all. Empty/1-2 byte and
   all-literal short inputs always fail (verified: 5/16 sweep cases).
2. **w == 9 would emit a zero-length tag** (unreachable): `wid` is
   `bitwidth(acc)+1`; the zigzag keeps every delta contribution <=
   0x7f, so acc <= 0x7f and wid <= 8 — w=9 can never occur. If it did,
   the flat tag index `prevw*8 + 9` would land on a `0000` pad entry
   (a zero-bit tag → decoder desync). Dead-code defect only; w==8
   legitimately wraps the flat index to the next row's col0
   (e.g. prevw2/w8 -> 0x061f = '011111' -> widtab slot7 -> wid8).
3. **Match lookahead reads past in+inlen**: the `cmpm.b` candidate
   compare runs up to 46 bytes past the input end. On the last
   positions a match is fabricated from *stale memory* — verified:
   the tail of the `abc` pack (len 31 vs 29) depends on what bytes
   the previous test left after the input buffer. Stream bytes for
   trailing positions are therefore memory-content-dependent.
4. **Decoder match-copy overruns out+ulen**: the len-byte copy loop
   writes the full match before the `out < end` check runs; the `abc`
   original stream ends with len=31 at outpos 19 of 48 — one extra
   byte past `end`. Same class as #3, decoder side.
5. **Literal runs over-emit at the tail**: a narrow literal token
   always emits its full run (5 deltas) even when fewer positions
   remain; deltas then encode bytes past in+inlen (paired with #3).
6. **`xsp_Sub[0]` stale after free**: the pack wrapper frees the
   0x22080 workmem every call but never NULLs xsp+52 (the pointer is
   dead after return — same pattern as the 1.2 sibling).
7. **No 68020 CPU gate**: the codec uses `bfins`/`bfextu`/`bfffo`
   (68020+) but LibInit never checks AttnFlags — on a 68000 it
   crashes instead of failing init. The 1.2 sibling added the gate.
8. **Descriptor built in code**: LibInit writes ~40 constant fields
   into private data instead of using a datatab — same bytes, ~80
   bytes of init code (matches original; not a defect per se).
9. **rt_EndSkip = 0**: RomTag EndSkip points at hunk+0 (sibling
   pattern).
10. **lenextra[0..1]/lentab[0..1] = 0**: len 0/1 unreachable — table
    padding. lenextra also doubles as the forced-'0' tag: the literal
    path `lea`s 0x664 (two bytes before the table) to fetch 0x0100.
11. **'0111' selector straddles the tested bit**: in inverted mode the
    `bfextu` for the width slot reads 3 bits *at* the position of the
    '1' it just tested — the selector is therefore `1` + next 2 bits,
    reaching slots 4..7 only. Faithfully reproduced (my first
    reconstruction read the 3 bits *after* the '1' — decoder desynced
    on every narrow-width stream).

## Analysis corrections (recorded for the record)

- Early reading logged the litpress gate as `>=7` vs decoder `>=8`
  (an "off-by-one defect"). Wrong: BSD objdump prints `bhis` for
  opcode 0x62, which is **BHI** (strictly higher, `!C && !Z`), not
  BHS/BCC (0x64). The real gates are `cmpaw #7,a5; bhi` (litcost) and
  `cmpaw #7,a5; bls` (marker rewrite) — i.e. both engage at
  litpress > 7, consistent with the decoder's `cmpw #8,d1; bcc`.
  Verified by gate trapping: the original evaluates the gate at
  a5=7 and takes the forced-'0' path.
- A "machine68k doesn't take `bcc` on equality" hypothesis was also
  disproved by direct micro-tests: `cmpl`/`cmpw`/`cmpb`/`cmpaw`/`cmpal`
  all set C correctly at equality and `bcc`/`bcs`/`scc`/`scs` behave
  normally.
