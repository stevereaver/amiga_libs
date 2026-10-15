---
type: Library
title: mathtrans.library 40.6 (7.4.95) "for 68040"
description: >-
  Third-party 68040 rebuild of the FFP transcendental math
  library by Martin Berndt: 17 SP* vectors implemented as
  full double-precision software kernels (the 68040 FPU has
  no fsin/fatan/fexp/flog10 hardware) with argument
  reduction, polynomial/rational approximations and an
  inline IEEE-64 coefficient pool; FFP<->IEEE converters;
  private DELEXP flag byte at base+0x2a.
timestamp: 2026-10-10T23:30:00Z
---

# mathtrans.library 40.6 (7.4.95) for 68040

Sibling of `mathtrans_40.6_FPU_` — same Martin Berndt
framework and the same FFP `SP*` API (mathtrans_lib.fd,
bias 30), but a completely different numerical engine.
Because the 68040 FPU omits the transcendental instructions
(`fsin`, `fcos`, `fatan`, `fsinh`, `fcosh`, `ftanh`,
`ftentox`, `fetox`, `flog10`, `flogn`, `fgetman`, `fgetexp`,
`fmod`, `frem`, `fscale`, `fsincos`, `fint`, `fintrz`),
this build ships **full software implementations**:
every vector converts its FFP argument to IEEE double,
runs a double-precision kernel (argument reduction +
polynomial/rational approximation in inline immediates),
and converts the result back to FFP.

## Binary facts

- sha256 `b18f7fe198ff2028629fbe5005241f9528f818d010254d26219eff13baf7ec81`, 6188 bytes
- single CODE hunk 0x177c bytes
- RomTag: RTF_AUTOINIT, RT_VERSION 40, NT_LIBRARY, pri 0
- RT_ENDSKIP points at the InitTable (hunk+0x6e), not module end
- name `mathtrans.library`; idstring
  `mathtrans 40.6 (7.4.95) for 68040\r\n(c) 1995 by Martin Berndt`
- module entry `moveq #0,d0/rts` (also ExtFunc target)
- InitTable: dataSize 0x2c, absolute-longword functab (21
  entries + -1L), InitStruct datatab, initFunc
- InitStruct: NT_LIBRARY, flags 0x06, version 40, revision 6
- init: requires AFF_68040; for exec V39+ also AFF_FPU40
- private DELEXP flag: bit3 of base+0x2a (not lib_Flags)

## Layout

- 0x000 module entry / RomTag / strings / InitTable / functab
- 0x0d6 InitStruct stream
- 0x0f8 LibInit, 0x128 LibOpen, 0x138 LibClose,
  0x148 LibExpunge
- 0x188..0x175f numerical code: 17 vectors + shared helpers
  (`_SPTieee`, `_SPFieee`, `_sp_floor`, `_reduce`,
  `_sin_poly`, `_cos_poly`, `_exp_dbl`, `_exp_sgl`,
  `_exp_poly`, `_log_core`, `_pow_int`) and inline
  IEEE-64 immediate constants
- 0x1760..0x177b constant pool `_ctab`: half (0x3fe0..),
  one (0x3ff0..), two (0x4000..), zero (4-byte long)

## Status

FULL — reconstructed (`source/`): C framework
(mathtrans.c, mtbase.h) + resident tables
(mathtrans_lib.s, datatab.s, endmodule.s) + verbatim
numeric code in math.s.  The 0x188..0x177b code+constant
region assembles **byte-identical** to the shipped binary
(5620 bytes, zero diffs); framework semantics verified by
disassembly.  Built with m68k-amigaos-gcc -m68040,
single-pass link; valid Amiga HUNK.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
