---
bundle: samp_1.0.library
status: complete
updated: 2026-10-15
---
# samp 1.0 'idents SAMP lib, (c) JAN 1990'

Early hand-rolled assembler sample (8SVX/IFF audio) utility
library. Plain resident (rt_Flags=0 — exec calls rt_Init directly);
init stores seglist+execbase in pc-rel scratch, opens dos.library,
and AddLibrary's an embedded 18-slot `4ef9` jump table whose tail
*is* the library node.

- `structures/layout.md` — hunk map, resident, jump table
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
