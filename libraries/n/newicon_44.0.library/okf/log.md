# newicon_44.0 — work log

- Parsed hunks: CODE 0x828B, DATA 0xbcB, BSS 8B; DREL16
  relocs (word offsets).  DATA carries absolute functab
  (13 entries) + InitTable + RomTag at +0x40.
- Identified as Stephan Rupprecht's NewIcons 44.0
  *emulation* stub over icon.library v44.
- Decoded: init gate (AFF_68020), open caller-gate vs
  "newicons" program name, lifecycle, xget/put/free/getdef/
  dupimg/ctrl/mkdef vectors, DEFAULTIMAGE fallback, remap.
- Wrote `source/newicon_lib.s` (skeleton + stubs) and
  `source/newicon.c` (register-arg wrappers + logic).
- Built with `/opt/amiga/bin/m68k-amigaos-gcc -m68000`
  (cross `as` for the skeleton); final lib 2952B.
- machine68k oracle `work/oracle.py`: fake exec/dos/
  icon.library, tag-protocol IconControlA, failure knobs.
  Iterated through decode fixes:
  - `TAG_IGNORE`/`GetDefaultType` branch sense inverted.
  - `bfexts` sign-extension → `SetTranspColor = flag&1?0:-1`.
  - tooltype name is `DEFAULTIMAGE` not `DELIMAGE`.
  - q2 tag order (30,22,26,18); DONE data = stack residue
    (normalized in the oracle).
- Result: 23 scenarios, all event-identical (lifecycle,
  open-gate variants, get/put/free/getdef/dupimg/ctrl/
  mkdef, alloc/dup/newdob/addfl/layout/gettags failure
  paths, unmapped→DEFAULTIMAGE recursion, icerr/mkerr).
