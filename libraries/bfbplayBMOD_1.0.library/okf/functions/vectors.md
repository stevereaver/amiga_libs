# Vectors (15, absolute long, LVO -6..-84)

| LVO | Target | Notes |
|-----|--------|-------|
| -6  | h0+0x130 | Open (opencnt++) |
| -12 | h0+0x13e | Close |
| -18 | h0+0x152 | Expunge |
| -24 | h0+0x198 | reserved -> 0 |
| -30 | h0+0x19c | -> 0xffffffef (-17) under null args |
| -36 | h0+0x34c | frees ctx (FreeMem 80B) -> 0x80 |
| -42..-72 | h0+0x3e6..0x514 | module ops -> 0 under stub args |
| -78 | h0+0x56e | AllocMem ctx (8B) -> handle |
| -84 | h0+0x5?? | -> h0+0x6b |

BMOD module format: "BMOD" magic checked in module-ops paths.
