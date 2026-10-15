---
type: Index
title: easyrexx_1.78.library — OKF index
---

# easyrexx_1.78.library — OKF index

- Binary: `binary/easyrexx_1.78.library` (3,016 bytes / 0xbc8;
  md5 `4c5c75ff4c16e7b4e7e7b070853719b7`)
- Identity: resident name `easyrexx.library`, id `EasyRexx 1.78
  (30.11.94)`, version 1, revision 78, `NT_LIBRARY` + `RTF_AUTOINIT`,
  pri 0.
- Kind: ARexx host-port / RexxMsg manager ("EasyRexx").  Creates
  uniquely-named message ports (`EASYREXX`/`AREXX` + `.%ld` retry),
  allocates a DOS object, sends RexxMsgs to a host port and collects
  replies, and dispatches inbound command strings through a
  name->key table.
- Hunks: h0 `HUNK_CODE` 0x2b5 longs (2772 B); h1 `HUNK_DATA` 6 longs
  (24 B) holding the InitTable at +4 plus two dead pad longs.  The
  near-data base `_gd` = h1; relocations are ordinary RELOC32 with a
  nonstandard descending-then-ascending offset order reproduced
  verbatim by `source/fixup.py`.
- Vectors: 17, absolute-long functab at h0+0x9d4 terminated by -1.
  See `functions/vectors.md`.
- Reconstruction: `source/easyrexx_h0.s` is generated verbatim by
  `work/genasm.py` (capstone disasm + data islands + mid-insn label
  splitting); `source/easyrexx_h1.s` is the hand-written DATA hunk;
  `source/Makefile` + `fixup.py` produce a byte-identical binary
  (md5 `4c5c75ff4c16e7b4e7e7b070853719b7`).
- Runtime: `work/oracle.py` (machine68k) — log identical for
  original and rebuild over the full lifecycle and every vector,
  including failure paths.
