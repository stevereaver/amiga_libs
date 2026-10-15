# Work log — bfbplayGMOD.library V1.0

- IRA NEWSTYLE disassembly produced `work/bfbG.asm`.
- Resolved: AUTOINIT RomTag, init table (dataSize 0xb2), absolute
  functab 14 vectors, datatab (same bytes as bfbplayPSID), strings
  (libname, idstring, dos/ciaa.resource/GMOD/desc).
- Decoded the GMOD session (80B, MEMF_CLEAR): type=7, running byte,
  modbuf@+2, modlen@+10, songsm1@+20 (word, modbuf+64()-1),
  cursong@+24 (0-based), fmtname@+26="GMOD", buf3@+38/len3@+42,
  playing@+56.
- Decoded the CIA replay chain: ensure_resources opens ciaa then
  ciab (in-place 'a'->'b' string patch); cia_start probes timers
  A/B on ciaa then ciab via AddICRVector, programs period 0x3781,
  CRx=0x11; ICR interrupt -> exec Cause -> softint -> modbuf+40 tick.
- Embedded module ABI: +20 play(d0), +24 stop, +40 tick, +64 songs.
- Reconstructed in C (bfbplayGMOD.c) + asm skeleton
  (bfbplayGMOD_lib.s: skeleton, strings, datatab, cur_sess global,
  tick dispatcher, cause trampoline, both Interrupt structs).
- Build: m68k-amigaos-gcc -m68000 -O2, links clean; header,
  strings, datatab byte-identical modulo relocs; interrupt tail
  byte-identical.
- 10 defects filed in findings/defects.md (string self-modify,
  unaligned fields, seek-return size, stub vectors, empty GetInfo,
  single global session, expunge-during-play dangles).
