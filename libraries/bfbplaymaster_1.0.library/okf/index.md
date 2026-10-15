---
type: Library
title: bfbplaymaster.library 1.0
description: >-
  bfbplaymaster V1.0 (03.08.1996) — master dispatcher for
  13 bfbplay* replayer sub-libraries; single CODE hunk,
  19 vectors, module-format magic table.
files:
  - source/bfbplaymaster_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# bfbplaymaster.library 1.0

Single CODE hunk (3332B).  `moveq #-1; rts` stub, Resident@+4
(AUTOINIT v1), InitTable@+0x474 (datasize 0xb2, functab->+0x484,
datatab->+0x4d4, initfn->+0x4f4).

- name 'bfbplaymaster.library'@+0x1e, idstring
  'bfbplaymaster.library V1.0 (03.08.1996)'@+0x34
- functab@+0x484: 19 absolute entries + ffffffff
- initfn opens dos.library only; user vectors dispatch to
  per-format replayer sublibs ('replayers/bfbplay*.library' —
  P61A/P60A/PT20/MED!/QUAD/DIGI/GMOD/WHIT/PSID/OKTA/THXS/HIPC/
  BMOD)
- module-magic sniff table ~0xb50-0xcd0: P61A/P60A/MMD0-2/
  M.K./SNT!/FORM/DIGI/GMOD/FLT4/XPKF/PSID/OKTA/CPLX/COSO/BMOD/
  THX/EMOD/EMIC/SONG/CMOD/_TP3/TFMX
- large error-string table @0x201-0x46e (16 messages)

## Build

`bfbplaymaster_h0.s` verbatim; head data (resident + strings +
InitTable + functab + datatab) raw through +0x4f4.
`fixup.py` splices the 29-entry RELOC32 tail.  Byte-identical
(md5 acc0c87939202924e0cf126ff1da26f7).

## Runtime

`work/oracle.py`: init, all 19 vectors, open x2, close x2,
deferred+real expunge.  Identical original vs rebuild.
