# Work log — memorymanage.library 1.01

- IRA disassembly (NEWSTYLE) produced `work/mm.asm`; several
  privileged and indexed instructions (`MOVEC`, `PTESTW`, `PFLUSHA`,
  `move.l d2,a2@(0,d1:w:4)`-style stores, `btst #1,...@(3,d1:w:4)`)
  came out as `DC.W` — recovered with raw `objdump -D -b binary`
  decoding at code+0x3a0..0x54f and 0x612.
- Resolved layout: AUTOINIT RomTag (dataSize 0x53, NULL datatab),
  absolute-pointer functab with 11 vectors.
- Mapped library base fields: seglist +34, rootnode/SRP +38,
  freelist +42, regionbuf +46, saved MMU block +50 (URP/SRP/DTT0/DTT1/
  ITT0/ITT1/TC.w/MMUSR.l), refcount +80, active flag +82.
- Decoded the three supervisor bodies: sv_loadregs (code+0x342,
  MOVEC writes + PFLUSHA + RTE), profile A @0x37c / profile B @0x396
  (identical 26-byte blocks), sv_ptest @0x5d0 (dfc=1; ptestw (a0);
  mmusr->d0), sv_readregs @0x612.
- Decoded MMUMap's real descriptor math (flags<<5&0x40 |
  flags<<4&0x20 | flags&4 | ~flags&1), the `table|2` indirect bit,
  and base-preserving child-table fills (0x40000-step mids from
  `root&0xfffc0000`, 0x1000-step leafs from `mid&0xfffff000`).
- Reconstructed in C (mm.c) + asm skeleton (mm_lib.s: RomTag,
  inittab, functab, strings, profiles, three supervisor thunks).
  Build: m68k-amigaos-gcc -m68000 -O2, links clean.
- Verified: header byte-identical modulo relocs; all vector targets;
  MMUAttach/MMUDetach/MMUMap/MMUTranslate codegen reviewed
  instruction-by-instruction vs the original (incl. GCC's countdown
  fill trick producing the same ascending descriptors and the
  pushed-d0 return quirk).
- Found+fixed reconstruction bug: SUPERVISED macro didn't declare its
  a0 operand — inlined MMUReadRegs pushed root instead of the saved
  block. Fixed by binding the arg explicitly.
- 12 defects/inconsistencies documented in findings/defects.md
  (garbage-SRP install, detach-restores-patched-profile, refcnt leak,
  d0 return quirk, etc.).
