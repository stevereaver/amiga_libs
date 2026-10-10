---
type: Log
title: Reconstruction log
---

# Log — mathtrans_40.6_040_.library

- Scanned: 6188-byte CODE hunk; initially mis-suspected to
  be a gate-variant of the 912-byte FPU sibling — actually
  a full software reimplementation (6.8x the size).
- Phase 1: disassembled with objdump -m m68k:68040
  (IRA cannot decode FPU opcodes); resolved all 21
  functab LVOs against mathtrans_lib.fd.
- Phase 2: decoded all 17 vectors + 9 internal helpers;
  mapped argument-reduction constants (4/pi, pi/8 splits,
  ln2 hi/lo, sqrt(1/2), log10(e)) as exact IEEE-64
  immediates; identified `_sp_floor`, `_reduce`,
  `_sin_poly`, `_cos_poly`, `_exp_dbl`, `_exp_sgl`,
  `_exp_poly`, `_log_core`, `_pow_int`.
- Generator: sequential walker over objdump output
  (handles multi-line FPU immediates, `0000` alignment
  pads, sign-extended branch targets); emits named
  labels for the 9 helper entry points + Lxxxx for
  local targets.
- Phase 3: framework = sibling template with the 68040
  init gate (AFF_68040; +AFF_FPU40 for exec>=39);
  math.s transcribed verbatim — pc-relative displacements
  emitted literally (gas computes the f23a disp base
  differently than the shipped encoding), `mulul`
  extension preserved as raw words, `_czero` as .long.
- Verify: 0x188..0x177b region assembles byte-identical
  (5620/5620 bytes, 0 diffs); framework disassembly
  semantically equivalent; functab ordering confirmed;
  valid HUNK produced by single-pass link.
- Phase 4: this OKF bundle.
