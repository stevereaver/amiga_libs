# lucyplay_5.0.library

"lucyplay 5.0 (17.02.2001) 68000" — Lucy game/multimedia playback
library. 5844B. Flat single CODE hunk (0x597 longs), AUTOINIT.

- Resident mid-hunk @h0+0x16c (26B extended); name->h0+0x188,
  id->h0+0x19c, init->h0+0x15c (InitTable).
- InitTable: dsize 0x52, ftab@h0+0x1c0 (26 abs-long vectors),
  dtab@h0+0x22c, initfn@h0+0xe0.
- Tail is DREL16 (36 word-offset entries ->h0), not RELOC32.
- Deps: dos37, lowlevel40, graphics, cybergraphics,
  Picasso96API.library + timer.device/ahi.device (OpenDevice).
