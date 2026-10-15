# mathffp.library 36.5

Commodore-Amiga, 6 Jul 1989. 1,480 bytes. The Kickstart 1.x-era
**FFP (Fast Floating Point) math library**, derived from Motorola
MC68343 floating-point firmware. Hunk 1 holds only a Motorola
copyright notice — reproduced in the reconstruction as a
same-length placeholder (verbatim notice not committed).

## Structure

- 0x3f3 overlay header, 4 hunks: code 0x134 lw, data 0x11 lw
  (the Motorola banner), two size-0 hunks.
- **Packed RomTag** (26 bytes, no pad word) at hunk0+0.
- InitTable @0x48: dataSize 0x22 (plain `struct Library`),
  word-offset functab, datatab, initfn = bare `rts`.
- **Word-offset functab** @0xf8: leading `0xffff` marks the
  offset format; each entry is a signed word offset measured
  from the table base; `-1` terminates.
- InitStruct datatab @0x74: ln_Type=9(NT_LIBRARY),
  ln_Name="mathffp.library", lib_Flags=6 (SUMUSED|CHANGED),
  lib_Version=36, lib_Revision=5, lib_IdString=
  "mathffp 36.5 (6 Jul 1989)\r\n" — two copies of the id string
  exist (one for RomTag @0x2a, one for the datatab @0x58).

## FFP number format

`[31:8]` = 24-bit normalized mantissa (binary fraction,
0x800000..0xffffff ≡ 0.5..~1.0), `[7]` = sign, `[6:0]` =
exponent biased by 64. Exact zero is all-zero. A value whose
exponent byte is 0 but mantissa nonzero is a *denormal* —
several routines leak these through unchanged instead of
normalizing.

## Register ABI (matches mathffp_lib.fd)

- Unary ops: operand in **d0**.
- Binary ops: `(leftParm,rightParm)` in **(d1,d0)**, but the
  machine computes `d0 OP d1` — i.e. `SPSub(d1,d0)` = d0-d1 and
  `SPDiv(d1,d0)` = d0/d1. The FD documents the mathematical
  operand names; callers pass (left,right) and get right-left,
  which for subtraction/division is the conventional result
  because the AmigaDocs define SPSub(fnum1,fnum2) as
  "fnum2-fnum1" style arguments.
- `SPCmp`/`SPTst` snapshot the real compare flags via exec
  `GetCC` (LVO -528) and leave them restored in the CCR on
  return, so callers can `bgt/ble/...` directly.

## Files

- `source/mathffp_lib.s` — packed RomTag, strings, InitTable,
  exact InitStruct datatab, word-offset functab, Open/Close/
  Expunge (transcribed), Motorola banner.
- `source/mathffp.c` — all 12 public functions, C transliteration
  of the m68k register flow.
- `source/endmodule.s` — RT_ENDSKIP marker at hunk end.
- `work/mathffp.asm` — IRA disassembly (gitignored).
- `work/model.py` — bit-exact Python oracle (gitignored).

## Verification

- All 16 vectors match `ndk/lib/fd/mathffp_lib.fd` (bias 30,
  plus management vectors at -6..-24).
- Host harness compared every function against a bit-exact
  Python transcription of the disassembly: **1,649,955 cases,
  0 mismatches** (normalized, denormal, zero, and extreme
  exponent inputs; divu-overflow and borrow-correction paths
  exercised ~48% of divisions).
- Generated hunk is a single 0x3f3 code hunk (2,908 bytes vs
  the hand-optimized original's 1,232); RomTag/InitTable/
  datatab/functab formats identical.

See `functions/vectors.md`, `findings/defects.md`,
`structures/ffp.md`.
