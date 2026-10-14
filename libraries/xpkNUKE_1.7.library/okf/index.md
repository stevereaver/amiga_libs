# xpkNUKE 1.7 — OKF index

"Nuke" XPK sublibrary 1.7 (06.06.1997) — LZ77 cruncher; older skeleton
of the xpkNUKE family (1.8/1.9 siblings committed).

- binary: `binary/xpkNUKE_1.7.library`
- source: `source/xpkNUKE.c` (codec) + `source/xpkNUKE_lib.s` (header)
- build: `cd source && make` — 68000 C+asm, behavioral reconstruction
  (not byte-identical; codegen/layout differs)
- oracle: `work/oracle.py` (machine68k) — corpus pack/unpack streams
  byte-identical vs original for all inputs incl. txt/ramp/rnd8k edge
  cases; pack+unpack round-trips verified
- plane: AMIGALIBS-151

See `functions/vectors.md`, `structures/layout.md`, `findings/quirks.md`,
`log.md`.
