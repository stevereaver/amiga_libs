---
type: Log
title: diskfont 1.3 (WB1.0) work log
---

# Work log

1. Parsed `binary/diskfont_1.3(WB1.0).library` (3912B / 0xf48):
   header 0x3f3, tablesize 13, first 0, last 12; 13 hunks
   (CODE/DATA only, no BSS, no SYMBOL/DEBUG), RELOC32 tails.
   No DREL16 in this binary (old absolute-long functab).
2. Found resident 0x4afc at h0+4: flags 0 (COLDSTART), ver 1,
   NT_LIBRARY, name 'diskfont.library'@h0+0x1e, idstr 'diskfont
   1.3 (5 Sep 1985)\r\n'@h0+0x30, rt_Init -> h0+0x4c.
3. rt_Init disasm -> MakeLibrary(-84) with functab h0+0x158 /
   datatab h0+0x130 / initfn h0+0x7a / dsize 0x38, then
   AddLibrary(-396).  functab = 6 absolute longs + terminator:
   Open/Close/Expunge/null + OpenDiskFont/AvailFonts trampolines
   in hunk 1.
4. Labelled inline data in hunk0 (resident, strings, datatab,
   functab) vs code; mapped hunks 10/11/12 as leaf thunk tables
   for dos/exec/graphics LVOs via a6 <- hunk2 globals.
5. `work/gen_source.py` emits `source/diskfont_h0.s`: verbatim
   .text bodies for all CODE hunks in hunk order + .data bodies
   for DATA hunks; inline data emitted as raw .byte; reloc-site
   operands emitted as literal .long/.word so the assembler
   reproduces the bytes exactly (fixup splices the real tails).
6. `source/fixup.py` asserts every reconstructed hunk body
   matches the original byte-for-byte, then rewrites the linked
   image as the original 13-hunk skeleton + verbatim RELOC32
   tails.
7. Build: `m68k-amigaos-gcc -m68020 -nostdlib -nostartfiles`
   + fixup -> `cmp` clean: **BYTE-IDENTICAL**.
8. `work/oracle.py` (machine68k, M68020): loads all 13 hunks
   (0x8000 stride @ 0x40000), applies RELOC32, emulates
   MakeLibrary + InitStruct + AddLibrary + OldOpenLibrary +
   CloseLibrary + AllocMem/FreeMem + Forbid/Permit + AddTail +
   all dos (-30/-36/-42/-84/-90/-102/-108/-126/-150/-156) and
   graphics (-72/-78/-480) vectors via trap cells.
9. Synthetic environment: FONTS: dir fib feeding one
   'topaz.font' descriptor (fileID 0x0f00, 1 entry
   'topaz/8' ysize8), LoadSeg returns a fake font segment with
   magic 0x0f80 at +0x16, and a 2-node resident TextFont list
   on GfxBase+0x8c ('topaz'/8, 'topaz9'/9).
10. Oracle exercised: rt_Init (a0=0x5a0000 fake seglist),
    libInit (opens dos+gfx), -6 Open, -24 reserved,
    -36 AvailFonts flags=3 (disk pass: Lock FONTS:, ExNext,
    Open/Read .font, emits type-2 entry; memory pass emits 1 of
    2 resident fonts) and flags=1 (memory only), -30 OpenDiskFont
    (gfx OpenFont miss -> Lock/Open/Read -> weigh -> LoadSeg ->
    magic check -> Forbid -> AddFont -> AddTail -> Permit),
    -18 Expunge while busy (->0 + DELEXP), -12 Close
    (self-expunge, still fontcount>0 ->0), then font accessors
    poked 0 -> -18 Expunge unlinks node, UnLoadSeg,
    CloseLibrary x2, FreeMem 92B, returns seglist 0x5a0000.
11. diff of original vs rebuilt oracle logs: **RUNTIME-IDENTICAL**
    (line-for-line, including 'afh: num=2' and expunge traces).
12. Wrote okf/: index.md, functions/vectors.md,
    structures/layout.md, findings/defects.md, log.md.
