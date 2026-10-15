---
type: Index
title: xpkPWPK_1.2(000).library
timestamp: 2026-10-15T00:00:00Z
---

# xpkPWPK.library 1.2

xpk sub-library by Michael Barsoom (1 Oct 2013): **PowerPacker**
packer ("xpkPP", XpkInfo sign `PWPK`). idstring
`$VER: xpkPWPK V1.2 (1 Oct 2013) by Michael Barsoom`.

## Layout

- Single CODE hunk, AUTOINIT word-offset function table,
  10 vector slots (-6 .. -60).
- XpkInfo name `xpkPP`, desc "Based on powerpacker.library",
  sign `PWPK`, flags 0x2a009; five modes Fast/Mediocre/Good/
  Very Good/Best (upto 20/40/60/80/100, pspd 18/17/14/11/9).
- Reserved vectors -24/-48/-60 are rts stubs.

## Status

BYTE-IDENTICAL - verbatim asm `source/xpkPWPK_h0.s` + `fixup.py`:
`cmp`-equal to shipped binary (md5 `41affc8a958ef52dcf35dc4ceb6ae9eb`).
machine68k oracle identical over module entry, InitStruct bootstrap,
all 10 vectors, XpkPackerInfo walk, pack incompressible -> -17
margin bail, mode-0 pack, unpack round-trip, deferred+real expunge.
