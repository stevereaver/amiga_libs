---
type: Log
title: Work journal
---

# Log

## 2026-10-10

- `make clean && make` in `source/` — built first try (two-pass
  genfunctab link).
- Reviewed `xpkRLEN.c`/`xpkRLEN_lib.s` against
  `work/xpkRLEN_1.4_020.asm`: encoder state machine (lit/pend/runlen,
  4+pend reserve check, ≥3-byte run seeding, 127 caps), decoder
  (0x80 quirk, no output bounds), Expunge/Close flow — all faithful.
- Fixed two fidelity bugs: `RT_ENDSKIP` pointed inside the hunk —
  added `endmodule.o` linked last so `_endcode` lands at module end
  as in the original (0x278); Makefile header comment said "V1.5",
  corrected to 1.4.
- Compared rebuild vs original: byte-identical through +0x0c
  (RT_ENDSKIP value), tables/descriptors equivalent at different
  offsets.
- Wrote the okf bundle.
