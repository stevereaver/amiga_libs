# intuisupport.library -- loader/packaging quirks

## Non-standard resident module

The file cannot be bootstrapped by stock exec:

- RomTag at code+4 looks normal except rt_Init points at code+4
  (itself) *before* relocation; the hunk-1 relocation block patches
  code+0x1a (the rt_Init field) with the DATA-hunk base, landing
  rt_Init at data+4.

- The InitTable at data+4 = {dataSize 0xb2, functab 0x67c,
  datatab 0, initRoutine 0x20} uses **raw code offsets** for
  functab/initRoutine -- there is no relocation inside the DATA
  hunk to turn them into addresses.  A custom loader must have
  added the code-hunk base to those fields by hand.

- Even then, initRoutine = code+0x20 decodes as `subl $0c48e7,d7`
  (junk), not the real initialiser at code+0x24 -- either the
  loader used a fixed entry convention or the shipped offset is
  off by four.

- Two `lea 0x0,a0` instructions inside the init (code+0x80,
  code+0x92) are relocated by hunk-1 relocs to DATA, giving the
  template source; a third at code+0x17e relocates `lea 0x2e` to
  data+0x2e (mid-string -- vestigial, a4 never used).

- First hunk-0 relocation entry targets code offset 0
  (code+0 = `moveq #0,d0` first word operand) -- the reloc
  rewrites the stub's immediate.  Same hunk0-offset-0 pattern seen
  in the xpk libraries.

## Register-parameter ABI

Every vector takes arguments in registers rather than the stack
(a6 = library base; d0-d7/a0-a5 per function).  The compiled code
pattern (moveml prologues, `lea N(a6),a4` private-data access,
register spill via exg) matches a fixed codegen, probably a
library-generator tool ("library maker" style).

## Dead mechanisms

- The init copies the 124-byte template then walks a fixup list:
  count = template[124], offsets from template[128].  Shipped
  count is 0 -> the mechanism never runs.
- Private fields +4..+19 copy the inittab image (0xb2 / 0x67c /
  0 / 0x20) -- dead at runtime.
