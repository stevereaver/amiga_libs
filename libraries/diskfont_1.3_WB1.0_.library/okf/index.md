---
type: Library
title: diskfont.library 1.3 (WB1.0)
description: >-
  diskfont.library 1.3 (5 Sep 1985) — the original Commodore
  disk-font library shipped with Workbench 1.0. 13 hunks,
  COLDSTART resident (no AUTOINIT): rt_Init runs its own
  MakeLibrary(-84)/AddLibrary(-396). Only 2 user vectors:
  OpenDiskFont -30, AvailFonts -36 (NewFontContents/
  DisposeFontContents are V34, absent here).
files:
  - source/diskfont_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# diskfont.library 1.3 (WB1.0)

13 hunks, RELOC32 tails only: CODE 0 (580B, resident+init+lib
vectors), CODE 1 (32B, vector trampolines), DATA 2 (16B globals:
libself/ExecBase/DOSBase/GfxBase), CODE 3 (636B, AvailFonts impl),
DATA 4 (16B "FONTS:"/".font" strings), CODE 5 (852B, weigh helper +
OpenDiskFont impl), DATA 6 (136B, "FONTS:" + 4 x 8-long style/ysize
penalty tables), CODE 7 (236B, str helpers), DATA 8 (0B, EMPTY),
CODE 9 (0B, EMPTY), CODE 10 (240B, dos.library C->reg thunks),
CODE 11 (104B, exec thunks), CODE 12 (60B, graphics thunks).

- Resident@h0+4: flags 0x00 (COLDSTART), version 1, NT_LIBRARY,
  name 'diskfont.library'@h0+0x1e, idstring 'diskfont 1.3 (5 Sep
  1985)\r\n'@h0+0x30, rt_Init->h0+0x4c
- rt_Init: MakeLibrary(functab@h0+0x158, datatab@h0+0x130,
  initfn@h0+0x7a, dsize 0x38, seglist d1), stores incoming a0
  (seglist) at lib+0x22, then AddLibrary
- datatab: ln_Type=NT_LIBRARY, ln_Name, lib_Flags=6
  (SUMUSED|CHANGED), lib_Version=1, lib_Revision=3, lib+0x36=0x0c
  (lh_Type=NT_FONT of the private font list at lib+0x2a);
  lib_IdString is NEVER initialized (stays NULL)
- initfn@h0+0x7a: stores execbase/self into hunk2, OldOpenLibrary
  (-408) 'dos.library' and 'graphics.library', NewList lib+0x2a;
  on failure CloseLibrary + FreeMem(lib-negsize)
- deps: exec.library, dos.library (v1), graphics.library (v1)

## Build

`diskfont_h0.s` verbatim .text (all CODE hunk bodies in hunk order)
+ .data (DATA bodies); `fixup.py` asserts the concatenated bodies
match, then re-emits the 13-hunk skeleton with the original header
and RELOC32 tails.  Byte-identical (cmp clean).

## Runtime

`work/oracle.py`: 13-hunk load + RELOC32 fixup, exec/dos/graphics
vector traps; MakeLibrary+InitStruct emulation; synthetic FONTS:
dir (one 'topaz.font' descriptor + LoadSeg font image) and a
2-node resident TextFont list.  Exercises rt_Init, libInit, all 6
vectors, AvailFonts flags 1 and 3, full OpenDiskFont disk path
(gfx OpenFont miss -> Lock/Read .font -> weigh -> LoadSeg ->
Forbid -> AddFont -> AddTail -> Permit), busy/deferred expunge,
font-node removal + UnLoadSeg, and final expunge returning the
stored seglist.  Identical original vs rebuild.
