---
type: Log
title: Work log
---

# Work log — mathtrans.library 40.6 (7.4.95) for 68881/82

## 2026-10-15
- Rewrote the reconstruction as a single verbatim asm file,
  `source/mt406_v.s` (same approach as the singtrans
  mst406_v.s): RomTag/InitTable/functab/datatab emitted in
  module order, every F-line word as raw `.short`, literal-0
  functab slot left for RELOC32.  `make` now links
  `-nostdlib -Wl,-s` to a **byte-identical** copy of the
  shipped binary (md5 b4eb6ee26278f6c81f0e26d71365f258); the
  old C model survives as `make cmodel`.
- New `work/oracle.py` (machine68k + python 68881 emulator,
  FFP args in d0/d1): init gate matrix, open x2, all 17 SP*
  vectors over FFP edge inputs incl. SPPow negative-x
  sign/parity paths and the moveq#0/bra.w early-0 stub,
  SPTieee/SPFieee over inf/NaN/subnormal IEEE inputs,
  deferred + real expunge.  Original vs rebuild logs diff
  clean -> runtime-identical.
- Confirmed quirks verbatim: SPFieee `lsl.w #8` dead work
  before `moveq #-1`, the andi.w #0xfeff/tst.l corner, and
  the beq past it targeting moveq#-1 (not the lsl.w).

## earlier
- Located binary (912 bytes, sha256 37cc1054...); identified
  `mathtrans.library` and the 17-entry SP* fd (bias 30).
- Mapped the AUTOINIT header: moveq#0/rts entry, RomTag
  (RTF_AUTOINIT, v40, NT_LIBRARY), RT_ENDSKIP -> InitTable,
  dataSize 0x2c, absolute-longword functab, InitStruct
  datatab (NT_LIBRARY, flags 6, v40.6).
- Disassembled with IRA + raw-hex decode (IRA cannot decode
  68881 opcodes — FPU words resolved empirically by
  assembling candidates through m68k-amigaos-as/objdump).
- Identified the shared converters: SPTieee = FFP->IEEE
  (add.l/eori/asr/subi/swap/rol.l#7, FFP0 -> IEEE0) and
  SPFieee = IEEE->FFP (swap/ror.l#7 + exponent re-bias with
  a bvs edge tree: clamp to 0, 0x7c/0x7e handling, or the
  0xFFFFFFFF+V error pattern).
- Decoded every vector: all unary ops are
  convert-op-convert wrappers (fatans, fsins, fcoss, ftans,
  fsinhs, fcoshs, ftanhs, fetoxs, flogns, fsqrts, fasins,
  facoss, flog10s); SPSincos = fsincoss d0,fp0:fp1, cos ptr
  arriving in d1 (movea.l d1,a0), cos stored first; SPPow =
  flogn/fmul/fetox with a
  negative-x path (|x|^y, fint parity via fmod(y,2), odd ->
  negate, non-integral y -> FFP 0).
- Verified the FFP layout empirically (mantissa[31:8],
  sign[7], exp7[6:0] excess-64) — host round-trip checks for
  1.0/-1.0/0.5/2.0/1.5/6.4/0 all correct; matches the
  documented Motorola FFP format.
- Reconstructed in C+asm: resident/functab/datatab in
  mathtrans_lib.s+datatab.s, framework in mathtrans.c,
  vectors+converters in math.s (code order mirrors shipped
  layout so short branches reach); built with -m68020
  -m68881; verified functab order, all 14 FPU encodings,
  branch targets and converter bytes against the original.
- Wrote OKF bundle (functions x21, structures, findings).
