# icon_1.104_WB1.0_.library

"icon 1.104 (9 Sep 1985)" — the WB1.0 icon.library, the earliest
shipped version. 6128B.

- 16 hunks (same per-function geometry family as 31.117/33.127):
  h0 CODE 0xa8, h5 CODE 0x287 main body, h6 DATA 0xd, five empty
  hunks; dense interleaved RELOC32 web.
- Resident @h0+4; name->h0+0x1e, id->h0+0x2b, init->h0+0x60.
- InitTable@h0+0x60: dsize 0x2e, ftab@h0+0x70, dtab@h0+0xbc,
  initfn@h0+0x160.
- initfn uses exec OldOpenLibrary (-408) for dos — the WB1.0-era
  convention, unlike the OpenLibrary(-552) of later builds.
