# Rebuild delta

`source/xpkCBR0_h0.s` is a verbatim GNU-as transcription of the CODE
hunk; `make` produces a BYTE-IDENTICAL binary (md5
`0243e290e331815dceb75ed3df6ccbed`, cmp clean).  The reloc32 tail is
stored in ascending order and matches GNU ld output — no fixup pass.
`work/oracle.py` (machine68k) drives every vector including real
pack/unpack round-trips; orig.log == rebuild.log.

The earlier GCC C model (`make cmodel`) is superseded — it rebuilt the
RomTag/functab/XpkInfo layout but with different codegen (and the C
encoder does not reproduce the shipped run-detection exactly).
