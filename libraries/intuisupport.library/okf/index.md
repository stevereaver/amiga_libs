# intuisupport.library 1.1

Small intuition/graphics helper library shipped as a two-hunk
HUNK file (2100 bytes: CODE 1772 + DATA 128, 21+4 relocs).

Authored by a code generator / custom build system (not standard
AUTOINIT): the RomTag's rt_Init field is patched by a cross-hunk
relocation to point at an InitTable stored in the DATA hunk, and
that table's funcTable/initRoutine fields hold raw code offsets
rather than relocated pointers.  As shipped, stock exec cannot
bootstrap it; a custom loader must have added the code base to the
InitTable fields (and entered the initialiser at code+0x24, not the
stated +0x20).

## Purpose

Support library for drawing AmigaOS-1.x-style 3D gadget boxes and
handling a fatal-error alert:

- builds two-Border "raised box" structures (top/left highlight +
  right/bottom shadow pairs),
- a 36-byte double-buffer list object (two equal-size buffers +
  state words),
- byte fill / clear / strlen / CopyMem helpers,
- a fatal-error alert that DisplayAlerts a fixed German text
  ("Nach Betaetigung einer Maustaste wird das Programm beendet !!"
  = "the program will be terminated after a mouse-button press")
  and then jumps into a caller-supplied abort routine,
- a DrawText helper that SetAPen/SetBPen/Move/Text's a caller
  object (rastport pointer at obj+50).

## ABI

Private register-parameter ABI: library base in a6, arguments in
d0-d7 and a0-a5 depending on the function (see functions/vectors.md).
Exec calls always use absolute-4 SysBase (`moveal 4,a6`).

## Structure

- RomTag at code+4; `moveq #0,d0; rts` entry stub at code+0.
- Manual init routine at code+0x24: sets ln_Type/ln_Name/flags/
  version/revision/IdString/seglist itself, copies the whole DATA
  hunk (124 bytes) into base+46 as private data, then walks a
  fixup table at data+124 (count 0 -> dead code), then calls the
  OpenLibrary bootstrap (code+0x5c8).
- Function table at code+0x67c: 15 absolute-longword entries,
  -1L terminated (LVOs -6 .. -90).
- Strings: "intuisupport.library" twice (name + IdString, both
  bare -- no $VER: cookie).
- DATA hunk (copied verbatim into private space):
    +0   ULONG 0
    +4   ULONG 0xb2     (dead copy of inittab dataSize)
    +8   ULONG 0x67c    (dead copy of functab offset)
    +12  ULONG 0        (dead datatab image)
    +16  ULONG 0x20     (dead initRoutine image)
    +20  char[61] "Nach Betaetigung einer Maustaste wird das
                   Programm beendet !!" + NUL
    +84  00 50 10 1c    alert string template bytes
    +88  "intuition.library"\0
    +106 "graphics.library"\0
    +124 ULONG 0        fixup count (empty)
  then appended by init at runtime:
    +124 IntuitionBase
    +128 GfxBase
  Private area total: 132 bytes; InitTable dataSize = 178
  (34 Library + 4 seglist + 8 pad + 132).

## Rebuild

source/intuisupport.c + intuisupport_lib.s, m68k-amigaos-gcc
-m68000.  The rebuild uses a conventional AUTOINIT InitTable in
.data (dsize 0xb2, absolute-longword functab, init pointer), so
the result loads under a normal exec -- the same routine then
reproduces the manual field setup and template copy.

Verified under a Musashi oracle (work/compare.py): identical init
behaviour, vector map, OpenLibrary sequence, DrawText graphics
calls, Make3DBorder structure bytes, buffer-list layout, and the
AbortAlert string bytes.

Plane: AMIGALIBS-99.
