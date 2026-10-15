---
type: Library
title: mathtrans.library 40.6 (7.4.95) "for 68881/82"
description: >-
  Third-party FPU rebuild of the FFP transcendental math
  library by Martin Berndt: 17 SP* vectors, each an
  FFP->IEEE conversion, one 68881 single-precision op, and a
  range-checked IEEE->FFP conversion back; real SPTieee and
  SPFieee converters; private DELEXP flag byte at base+0x2a.
timestamp: 2026-10-10T22:40:00Z
---

# mathtrans.library 40.6 (7.4.95) for 68881/82

Sibling of `mathieeesingtrans_40.6_FPU_` /
`mathieeedoubbas_40.6_FPU_` — same Martin Berndt framework
(AUTOINIT, absolute-longword functab, 0x2c-byte base,
AFF_68020+AFF_68881 gate, private DELEXP byte) exposing the
classic FFP `SP*` API from `mathtrans_lib.fd` (bias 30).

Unlike the IEEE-native singtrans build, this library's
arguments are Motorola FFP values: every vector runs an
FFP->IEEE input conversion (the public SPTieee routine), one
68881 single-precision operation, and a range-checked
IEEE->FFP output conversion (the public SPFieee routine).

## Binary facts

- sha256 `37cc1054478cd30556d5f49b3dc082469368ee94fc46ede2ba2acb84a525767b`, 912 bytes
- md5 `b4eb6ee26278f6c81f0e26d71365f258`
- single CODE hunk 0x2e0 bytes
- RomTag: RTF_AUTOINIT, RT_VERSION 40, NT_LIBRARY, pri 0
- RT_ENDSKIP points at the InitTable (hunk+0x72), not module end
- name `mathtrans.library`; idstring
  `mathtrans 40.6 (7.4.95) for 68881/82\r\n(c) 1995 by Martin Berndt`
- module entry `moveq #0,d0/rts` (also ExtFunc target)
- InitTable: dataSize 0x2c, absolute-longword functab (21
  entries + -1L), InitStruct datatab, initFunc
- InitStruct: NT_LIBRARY, flags 0x06, version 40, revision 6
- init: clears OpenCnt, stores SysBase/SegList, requires
  AFF_68020 && AFF_68881
- private DELEXP flag: bit3 of base+0x2a (not lib_Flags)

## Status

BYTE-IDENTICAL + RUNTIME-IDENTICAL — `make` assembles
`source/mt406_v.s` (verbatim asm, raw .short for all F-line
words) and links `-nostdlib -Wl,-s` to the shipped 912-byte
module (md5 `b4eb6ee26278f6c81f0e26d71365f258`); the earlier
C framework stays buildable as `make cmodel`.  machine68k
oracle (`work/oracle.py`, python 68881 emulation through the
line-F vector) runs identical logs on the original and the
rebuild — init gate matrix, open/close/expunge lifecycle,
all 21 vectors incl. FFP edge inputs, Pow sign/parity paths
and the SPFieee error conventions.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
