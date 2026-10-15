# xpkSQSH_1.10(a).library — OKF index

- Binary: `binary/xpkSQSH_1.10(a).library` (2,936 bytes, single 3E9
  hunk of 701 longs = 2,804 bytes code)
- Identity: `xpkSQSH 1.10 (6.3.94)` by John Hendrikx; libname
  `xpkSQSH.library`, XPK ID `SQSH`, lib revision 10
- **The real 1.10**: a 68000-COMPATIBLE reimplementation of the 1.00
  codec — the hunk contains **zero** bitfield instructions (hand-
  written `btst` bit loops replace `bfins`/`bfextu`/`bfffo`), a
  restructured encoder core (~0x3d8–0x761) and a new decoder
  (~0x762–0xb11) whose tail is the fragment orphaned as dead overlay
  in `xpkSQSH_1.10.library`.
- Vector/functab/InitTable layout identical to 1.00 (absolute-long
  table, same 10 target offsets); LibInit builds the same descriptor
  (dataSize 0xa8, identical constants).
- Codec semantics identical to 1.00 — all 16 sweep streams
  byte-identical to both the (a) original AND the 1.00 original, so
  the format is unchanged. Cost arithmetic uses `divu.w`/`mulu.w`
  (68000 has no 32/32 div or 32x32 mul).
- Reconstruction: `source/xpkSQSH.c` (same codec as 1.00, with
  `divuw`/`muluw` asm helpers for the cost divisions/multiplies),
  `source/xpkSQSH_lib.s` (same skeleton as 1.10(older)), built
  **-m68000** for CPU fidelity.
- Verification (machine68k, M68020): rev=10, correct idstr and
  descriptor, 16/16 streams byte-identical, all round-trips pass.
- Family map: 1.00 (020 code) -> 1.10(older) (1.00 code + 1.10
  metadata, truncated) -> 1.10 (damaged repack of (a)) -> 1.10(a)
  (this file: 68000 build) -> 1.2_000 / 1.2_020.

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
