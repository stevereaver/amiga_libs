---
type: Runbook
title: Work log — zlib_3.2.library
---

# Log

## 2026-10-10

- Parsed hunk header: 6 hunks (3 code / 2 data / 1 bss). RomTag at hunk0+4:
  RTF_AUTOINIT, NT_LIBRARY, ver 3, init → {dataSize=0x22, FUNCTABLE, DATATABLE,
  INITFUNCTION}.
- FUNCTABLE (in data hunk 3): 24 vectors + terminator. Cross-checked relocs:
  entries 0-10 → hunk0 (m68k), 11-17/20-21/23 → hunk1 (**PPC code** —
  `7c0802a6`=mflr r0, `4e800020`=blr), 18-19/22 → hunk0.
- Identified binary as Aminet `util/libs/zlib-library.lha` v3.2 by Achim
  Stegemann (StormC4 GCC, `__MIXEDBINARY__`, WarpOS). Downloaded archive;
  binary is byte-identical to shipped `Libs/zlib.library`.
- Recovered upstream sources from the archive into `source/`; resolved all 20
  API LVOs via `zlib_lib.fd` (10 `GZ_*` m68k + 10 `PPCGZ_*` WarpOS).
- Compile-verified every 68k-side unit with m68k-amigaos-gcc 16.2
  (`-fbaserel -msmall-code -D__STORMGCC__`, compat shims in `source/compat/`).
  Only nit: `s->file = NULL` on BPTR needs `-Wno-int-conversion`.
- Recorded inconsistencies in [findings/](findings/index.md).
- Follow-ups: PPC hunk not disassembled/decompiled (no PPC toolchain); StormC
  runtime init (hunk0 tail) only partially mapped; link not reproducible
  without StormC mixed-binary runtime.
