# Vectors (6, absolute long, LVO -6..-36)

| LVO | Target | Notes |
|-----|--------|-------|
| -6  | h0+0xc6  | Open |
| -12 | h0+0xd4  | Close |
| -18 | h0+0xe8  | Expunge |
| -24 | h0+0x126 | -> 0 |
| -30 | h0+0x12a | PT play/init: OpenDevice audio.device,
        |      |       OpenResource ciab.resource, misc/misc-6 calls,
        |      |       exec -330/-294; -1 under stub args |
| -36 | h0+0x162 | stop/free: misc-12, exec -450/-336; -1 stubbed |
