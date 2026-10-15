---
type: Function
title: xpkRLEN framework + INITFUNCTION
---

# Framework

`dataSize 0x13a` — base = `struct Library`(0x22) + seglist(4)
+ 20-byte gap + 0x100 copied template.

## INITFUNCTION (d0=base, a0=seglist)

SAS/C-style data init:
1. writes base fields manually: ln_Type=9, ln_Name, flags=6,
   version=1, revision=0, idstr, seglist@0x22
2. copies the 256-byte template SECSTRT_1 -> base+58
3. fixup pass: for each offset in the reloc list at
   data+0x100 ({0xe2,0xb6,0xb2,0xae}), `*(base+58+off) +=
   base+58` — descriptor pointers become absolute
4. returns base

## LibOpen / LibClose / LibExpunge

Standard: Open increments lib_OpenCnt + clears DELEXP;
Close decrements and expunges on zero-with-DELEXP; Expunge
sets DELEXP when open else Remove+FreeMem(seglist).

## Null vector

The entry stub `moveq #0,d0; rts` serves LVO -24 (ExtFunc);
FUNCTABLE points -24 and -42/-48/-60 at stubs.
