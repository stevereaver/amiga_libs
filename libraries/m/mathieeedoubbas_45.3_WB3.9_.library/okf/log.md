---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-15
- Parsed 3612-byte single-CODE-hunk module.  RomTag is
  RTF_COLDSTART (not AUTOINIT like the 40.x siblings): rt_Init @0x7a
  self-bootstraps via MakeLibrary(-84)/AddLibrary(-396).
- init decodes as: stash seglist (a0) into code cell @0x17e;
  OpenResource(-498,"fpsp.resource") -> d4; functab := tabD if
  fpsp ok, else tabC if AttnFlags bit4 (AFF_68881), else tabB;
  MakeLibrary(functab, datatab@0xf6, codeInit=0, dataSize=64, seg=0);
  lib+0x34/+0x38 = stub (clr.l d0;rts), lib+0x34 = fpcr-init hook
  @0xdbc when attn&0x10; lib+0x22 = attn&0x10; lib+0x28 = SysBase;
  lib+0x3c = fpsp base; AddLibrary.
- Three word-offset functabs mapped to 16 vectors each; shared
  integer bodies for Cmp/Tst/Abs/Neg/Ceil; FPU and software
  variants of Fix/Flt/Add/Sub/Mul/Div; three Floor variants
  (fintrz/fint for 68881, fpsp.resource -30 for 040, software).
- Byte-exact rebuild via generated verbatim .short source
  (`work/gen_source.py` -> `source/mathieeedoubbas_45.3_h0.s`),
  fixup.py splice of header+reloc tail.  First attempt clean:
  md5 9ca1dfb8c3bf809410a47b57eee5fddb.
- oracle.py adapted from the 040 sibling; extended the fpcr-move
  emulation to (sp)+/-(sp) EAs and added the fpsp.resource -30
  call gate (d0 selector: 1=fint, 3=fintrz, operand in fp0).
  init matrix proves: fpsp present -> tabD regardless of AttnFlags;
  no fpsp -> tabC only when attn&0x10 (a bare 040 with no
  fpsp.resource falls back to the SOFTWARE table); else tabB.
  orig.log == rebuild.log, diff clean.
- NOTE: a concurrent agent pass briefly dropped a generic
  (dsp3210-derived) oracle over work/oracle.py; restored the
  full FPU-aware oracle and regenerated both logs.
