---
file: defects
---
# Findings

- Degenerate resident: flags claim AUTOINIT (0x80) but
  rt_Init points at the RomTag itself (body+4). exec
  InitResident would read InitTable.DataSize=0x4afc0000
  and fail — so this lib was never loadable through
  OpenLibrary/InitResident; it must be initialised by the
  host app calling the real initfn directly.
- No negative jmp-vector area — nonstandard dispatch via
  stored functab pointer + forward table.
- h0 declared size undershoots physical body by 4B.
- Dead bsr to a moveq#0/rts stub inside initfn.
