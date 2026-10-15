# Rebuild delta

`source/xpkCYB1_h0.s` is a verbatim GNU-as transcription of the CODE
hunk; `make` produces a BYTE-IDENTICAL binary (md5
`51c68810ef67538e734e291c15493bd8`, cmp clean).  The reloc32 tail is
stored in ascending order and matches GNU ld output — no fixup pass.
`work/oracle.py` (machine68k) drives every vector; orig.log ==
rebuild.log.

The earlier GCC C model (`make cmodel`) is superseded — it rebuilt the
RomTag/functab/XpkInfo layout but with different codegen.
