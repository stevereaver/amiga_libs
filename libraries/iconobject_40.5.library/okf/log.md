# Reconstruction log

- Parsed hunk file: 2 hunks, CODE 0x23f LW + DATA 0x5c LW, RELOC32 only.
- No RomTag in CODE — SAS/C library: RomTag/InitTable/functab/strings
  all in the DATA hunk; code refs data via absolute .l fields.
- work/genasm.py: capstone 68000 linear sweep of hunk0 (3 regions;
  0x000-0x7fe, 0x800-0x8e2, 0x8e4-0x8fa; `0000` pads between).
  Reloc fields emitted as `.short` prefix + `.long sym`; data symbols
  resolved into hunk1 source. 4 mid-insn branch targets emitted as
  .short splits. moveq>0x7f normalised to signed.
- source/iconobject_h1.s hand-written: strings + functab + InitTable +
  RomTag + 5 zeroed base globals.
- make: m68k-amigaos-gcc -m68000, hunks.x SECTIONS .h0/.h1, fixup.py
  rewrites RELOC32 groups in original order, verifies vs binary/.
- Result: BYTE-IDENTICAL (md5 ee8b8bffa7aa63500a4b3f51f527457c).
- work/oracle.py: machine68k, CODE@0x40000 DATA@0x60000 LIB@0x100000,
  fake exec + stubs for iffparse/dos/intuition/utility/datatypes.
  AUTOINIT lib built from DATA+0x140 romtag. Exercises: init
  (InitSemaphore/NewList/4x OpenLibrary), first-Open DEVS:Datatypes
  scan (dos pattern+lock+ExNext, iffparse parse of 'icon'/'aico'
  collection chunk, datatype sublib open + call, Enqueue), all 7 user
  vectors, close/deferred-expunge w/ node teardown + FreeMem.
- Result: RUNTIME-IDENTICAL (60 log lines, all OK).
