---
bundle: dgsmus_2.1.library
status: complete
updated: 2026-10-15
---
# dgsmus.library 2.1 (24-Aug-93, (c) Optonica Ltd)

Optonica "DG SMUS" music player library (Insight/CDTV era
multimedia titles).  Three hunks: CODE (RomTag + InitTable +
player code, 0x39b longs), DATA (globals + period tables,
0x9a longs), DATA|CHIP (248-byte square-wave fallback
sample, 0x3e longs).  Resident @h0+4 flags 0x80 ver 2,
rt_Init -> InitTable @h0+0xae, 21 absolute-long vectors.
Open() pulls in six sub-libraries (dos, graphics, toolkit,
dgaudio, dg8svx, dgiff); playback runs in a subtask
installed via exec AddTask.

- `structures/layout.md` — hunk map, resident, InitTable,
  DATA-hunk globals map
- `functions/vectors.md` — LVO table + behavioural notes
- `findings/defects.md` — quirks (dead InitStruct byte,
  COLDSTART flag vs. InitTable, open-time sublib chain)
