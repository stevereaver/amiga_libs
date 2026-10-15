# mhimpegit.library 1.1 — quirks & defects

## Defects (reproduced faithfully)

- **AllocDecoder leaks an OpenLibrary on every failure path.** `_v5`
  opens prelude.library, then on bad version / missing MPEGit bit /
  AllocVec failure it calls `_errf` and returns 0 — it never
  CloseLibrary()s and never clears `_gd+0xc`. The next AllocDecoder
  call opens prelude AGAIN and overwrites the pointer: one leaked
  open-count per failure. Verified in the oracle: a failed alloc
  leaves `_gd+0xc` set, and Expunge's `_closelibs` closes it once
  (still short of the leaked count).
- **-72 vector is an empty `rts`** — returns whatever was in d0.
  Pause/unimplemented; callers see a garbage return value.

## Quirks

- Version check is `ver>5 || (ver==5 && rev>=6)` — i.e. "at least 5.6"
  per the error string, but a hypothetical 6.0 also passes.
- SetParam scales 0..100 input by exactly `floor(v*0xF0000/50)>>16`
  = 0.3x (v=50 -> 15, v=100 -> 30). Commands 3/5/6 map to tags
  0x8000003c/0x8000003d/0x8000003b — i.e. command order is scrambled
  vs. tag order.
- SAS/C encodings that gas canonicalizes had to be emitted raw:
  `and.b #imm,d0` (`c03c` x2), `sub.l #imm,d0` (`90bc` x4),
  `cmp.l #imm,d1` (`b2bc` x4), `cmpa.l #imm,a1` (`b27c` x3).
- `_errf` calls exec RawDoFmt (-0x24c) with a NULL format string
  (a0=0) — it relies on SAS/C-CRT-specific behavior; the parameter
  array is `{0x14, 0, _name, arg, "Abort :/"}`.
- DREL16 (`0x3f7`) relocation format with a quirky unsorted offset
  order; hunk1 advertises 16 B in the header but stores a 4 B body.
- `(4).l`-style absolute addressing for `_gd+N` globals — 67 fields in
  hunk0 relocate into the 4-init-byte hunk1.
