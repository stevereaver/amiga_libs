# bfbplayBMOD_1.0.library

"bfbplayBMOD.library V1.0 (15.10.1996)" — BMOD module player library
(BMOD module format by Tuomas Lukinmaa). 5504B, m68000.

- Flat single-hunk AUTOINIT (CODE 0x537 longs), 28 RELOC32 slots ->h0.
- Extended 26-byte resident @h0+4 (extra ptr @+0xa -> h0+0x14dc);
  `moveq#-1/rts` stub at body+0.
- Name ->h0+0x1e, id ->h0+0x32; embedded strings "dos.library", "BMOD",
  "BMOD module format by Tuomas Lukinmaa."
- InitTable @h0+0x92: dsize 0xb2, ftab->h0+0xa2, dtab->h0+0xde,
  initfn->h0+0xfe. 15 absolute-longword vectors.
- initfn opens dos.library.
