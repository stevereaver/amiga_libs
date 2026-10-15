---
bundle: fifo_37.3.library
status: complete
updated: 2026-10-15
---
# fifo.library 37.3

'fifo.library 37.3 (03.03.95)' — named-pipe/FIFO device-support
library. Plain resident (flags=0): rt_Init@h0+0x50 is a thunk into
the real init@0xe0, which builds the library via MakeLibrary with
the functab in the DATA hunk. 10 vectors.

- `structures/layout.md` — hunk map, resident, thunk table
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
