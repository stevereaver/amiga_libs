# cddb.library 44.999 — quirks & defects

- Hand-rolled init, not InitStruct: datatab=0; initfn writes
  ln_Type/name/flags/ver/rev/idstr directly and builds the ctx.
  Version/revision are produced by `lea 0x2c,a1`/`lea 0x3e7,a1`
  address-constant tricks (44/999), not immediates.
- Overlapping-instruction copy loop: `cmpiw #0x1cd9,d0` at h0+0x7a
  embeds `moveb (a1)+,(a6)+` (0x1cd9) which the `bccs` re-enters.
  Same idiom at 0xb8 (`cmpiw #0x200d` over `movel a5,d0`), 0x1b8
  (`cmpiw #0x7000` over `moveq #0,d0`) and 0x2a0 (`cmpiw #0x12d8`
  over `moveb (a0)+,(a1)+`) in strncpy.
- -24 vector is the relocated h0+0 DOS stub (`moveq #0,d0; rts`),
  not NULL — functab entry stores 0 and picks up a h0 reloc.
- -36 vector is a pure stub returning 0 (dead API slot).
- -48 error lookup indexes ctx+0x1c (the copied table) with
  errcode*4 for codes 0..10; out-of-range -> "Unknown error".
  Entry count is effectively 12 although 14 table slots exist
  (last two are the runlist/stub function pointers).
- _runlist's done-flag at ctx+0x64 is OUTSIDE the 96-byte h1 copy,
  so it starts zeroed from lib memory rather than the h1+0x64 value.
- fn-list built at ctx+0x4c = {0x8b0=_runlist itself, 0x9ac=stub,
  0=term}; runner pre-increments the cursor so it only ever calls
  the 0x9ac stub (`movew #4,d0` / stray bytes) on first pass.
- RomTag EndSkip (h0+0xa) and MatchTag (h0+0x6) carry h0->h0
  relocs — linker emitted, harmless on exec scan.
- h1 reloc order ends ...0x1c,0x08,0x10 (0x08 before 0x10) —
  non-descending tail quirk replicated in fixup.py.
- initfn frame: `subqw #8,sp` BEFORE `moveml` (gap used as scratch
  at sp+24), unwound by matching `addqw #8,sp` after moveml pop.
