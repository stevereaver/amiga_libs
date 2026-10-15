# xpkSQSH 1.10(a) — defects & inconsistencies

Codec behavior identical to xpkSQSH_1.00 — all defects in
`libraries/xpkSQSH_1.00.library/okf/findings/defects.md` apply
(past-end match overread, decoder copy overrun, literal run
over-emit, w9 dead-tag path, stale xsp_Sub[0], output budget = inlen).

Specific to (a):

1. **-60 vector lands mid-data**: functab entry -60 -> 0x2f4 points
   into a small data block (`00 00 00 00 00 08 00 00 04 6a` at
   0x2f2–0x2fb) rather than a code stub — harmless because xpk never
   calls the reserved vectors.
2. **(a) is the source of xpkSQSH_1.10's dead overlay**: the plain
   1.10 file is this build truncated at 525 longs with a 1.00-style
   reloc+END inserted — its orphaned 704-byte tail is this build's
   bytes 0x8b8–0xb77 verbatim.
