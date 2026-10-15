# xpkTDCS — RE log

## 2025 — session

- IRA disasm already in work/. Froehling xpksub layout confirmed:
  word-offset functab, same lifecycle, same find/insert code as
  xpkLZW5 (byte-identical asm for the chain walk).
- Descriptor decoded: "Sarnath's Doom" / 'TDCS' / "LZSS family
  020+ V1.5"; modes cremation 33 / ashes 67 / oblivion 100,
  packspeed 18/8/6, unpackspeed 560, ratio 397/411/415.
- Format deltas vs LZW5 established by binary diff:
  * emit: len-3 fields (no +1), tier caps l3≤3/l3≤15
  * decoder: +3 len base, zero-word check ONLY on flag-11 path,
    10-vs-11 flag bit tested before the token read
  * terminator: flag 11 (`3 << bitpos`) + zero word (LZW5: bset)
- PackReset fill counted from the binary's own movem sequence:
  3 + 14 + 14*4*1260 = 70,577 longs — NOTE: the earlier LZW5
  reconstruction used 88,217 (5/iter), which over-fills by
  17,640 longs. That is a reconstruction bug in xpkLZW5.c that
  needs a follow-up fix; the binary is 4 movem/iter.
- C reconstruction adapted from xpkLZW5.c with the deltas above.
- Host suite: 1156 clean round-trips, 841 bound (-17), 1002
  shipped-tier-defect corruptions, 0 real fails over 3000 trials.
- Byte-exact: 120/120 sampled streams match an independent
  Python model (incl. corrupt-tier outputs); descriptor, mode
  chain, strings byte-identical to the shipped binary; all 10
  functab targets resolve.
