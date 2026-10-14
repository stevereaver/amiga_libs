# cyberlayers_40.8.library -- quirks & inconsistencies

1. **Nonstandard relocation record**: tag `0x3f7` with 16-bit
   {count, hunk, offsets...} groups -- a DREL16-style encoding not
   produced by standard Amiga linkers (which emit 0x3ec RELOC32).
   The 0xa EndSkip field is relocated against *hunk1*, making the
   resident span both hunks.
2. **Patch table fn 0x530**: the -126 entry points two bytes into the
   `48e7` instruction's operand area only by apparent accident of
   layout -- actually the CYBL block @0x51e uses an 18-byte header so
   0x530 is its true entry point.
3. **Version-gated install**: `_install` aborts ALL six patches if
   any CYBL block's minimum exec version (fn-14) exceeds the running
   exec version -- an all-or-nothing guard.
4. **Trampoline convention**: installed blocks get {ourlib, oldfn}
   written into their header (fn-8, fn-4); block 1 tails via
   `movel pc@(-12),sp@-; rts` -- pushing the saved original then rts.
5. **Self-call conversion**: the clone scan converts `jmp pc@(d16)`
   self-calls to layers -126 into `jsr a6@(-126)` so the replacement
   is vectored.
6. **Whole-vector redirection**: all 33 layers.library vectors
   -30..-216 are SetFunction'd into a RAM clone registered as
   `layersdummy.library` -- the system runs the copy, not the ROM.
7. **-24 vector is a null stub** and doubles as the function pointer
   stored at lib+50 during init.
8. Init aborts (returns the zero OpenLibrary result) only if
   `cybergraphics.library` v40 fails; layers/graphics v39 results are
   stored without checks.
