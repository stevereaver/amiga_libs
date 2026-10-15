# Vectors (14, absolute long, LVO -6..-84)

| LVO | Target | Notes |
|-----|--------|-------|
| -6  | h0+0x166 | Open: `addq.w #1,lib+0x20` opencnt++, `bclr #3,lib+0x22`, ret a6 |
| -12 | h0+0x174 | Close: unconditional `subq.w #1,lib+0x20`; on 0 + flag bit3 -> Expunge |
| -18 | h0+0x188 | Expunge: cnt!=0 -> set flag bit3 ret 0; else Remove + CloseLibrary(lib+0x28 dos) + FreeMem(34+dsz), ret seglist (lib+0x2c) |
| -24 | h0+0x1ce | reserved -> 0 |
| -30 | h0+0x1d2 | InitModule: tag scan fn h0+0x15f6 (tags 0x80000001/2/3/7/8), allocs 80B session ctx a0+4, dos Open(-30, MODE_OLDFILE) + Seek(-66) file source; -> -17 on null args, -8 alloc fail, -6 open fail, -14 if !AFF_68020, -15 load fail |
| -36 | h0+0x434 | EndModule: stops playback, releases CIA int + buffers, FreeMem 80B ctx -> 0x80 |
| -42 | h0+0x4c0 | StartModule: lazy-opens ciaa/ciab.resource (h0+0x64c, self-modifying name patch), AFF_68020 gate -> -14, installs CIA timer int -> -13/-15 on failure, sets playing flag -> 0 |
| -48 | h0+0x554 | StopModule: halts tick, clears playing, sets paused flag -> 0x80 under stub args |
| -54 | h0+0x578 | ContModule: !playing && paused -> resume -> 0 |
| -60 | h0+0x59c | stub -> -1 |
| -66 | h0+0x5a8 | stub -> -1 |
| -72 | h0+0x5b4 | SetSubsong: d0 in [0,sess+0x14) -> sess+0x18, ret current |
| -78 | h0+0x5da | GetSubsongNames: counts NUL-terminated names in module, AllocMem(n*4+8) -> {count, 20, name ptrs} at sess+0x26; -> -8 alloc fail, handle |
| -84 | h0+0x644 | GetInfo -> h0+0x85 "THX Sound-System by Manfred Linzner (Pink/Abyss) and Martin Wodok (Dexter/Abyss)." |

CIA timer helpers: jump stubs h0+0x7b4..0x7c8 -> bodies h0+0x87c/0xaca/
0xb74/0xc24/0xc6a; AddICRVector via cia res -6, RemICRVector -12;
interrupt node named "BFBPlay CIA timer." (h0+0x79c); mixer pokes
$dff096/$dff0a0.. audio regs.
