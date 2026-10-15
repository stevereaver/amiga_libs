# Vectors (13, absolute longword, LVO -6..-78)

| LVO | Target | Notes |
|-----|--------|-------|
| -6  | h0+0x0d0 | Open: bumps opencnt, returns lib/segment ptr |
| -12 | h0+0x1fe | Close: dec opencnt, deferred expunge |
| -18 | h0+0x268 | Expunge |
| -24 | h0+0x000 | Reserved stub (relocated-zero slot -> CODE+0) -> 0 |
| -30 | h0+0x696 | RGHitTest (symbol `_RGHitTest` in HUNK_SYMBOL) -> 1 |
| -36 | h0+0x652 | RGCallMethod (symbol `_RGCallMethod`); exec -210/-690 activity |
| -42 | h0+0x5c8 | gadget helper (exec -690) |
| -48 | h0+0xd26 | |
| -54 | h0+0xebc | -> h1 base (returns DATA ptr) |
| -60 | h0+0x5ec | exec -198 (CopyMem) |
| -66 | h0+0x376 | -> 0x80000001 |
| -72 | h0+0xc72 | |
| -78 | h0+0x6e8 | |
