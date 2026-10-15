---
file: vectors
---
# Vectors

Absolute-long functab @hunk0+0x88, 13 entries.

| LVO | target | role |
|-----|--------|------|
| -6  | +0x13c | Open |
| -12 | +0x14a | Close |
| -18 | +0x158 | Expunge |
| -24 | +0x00  | reserved -> stub |
| -30 | +0x1a6 | utility call (dos -84 path observed) |
| -36 | +0x258 | AllocMem/CreateMsgPort-ish (exec -132/-138) |
| -42 | +0x37e | returns 0 |
| -48 | +0x2f4 | port teardown (exec -132/-138) |
| -54 | +0x4ec | opens asl+intuition lazily -> -1 under stubs |
| -60 | +0x58a | opens keymap.library, LoadSeg `sys:devs/keymaps/` |
| -66 | +0x6a6 | returns 0 |
| -72 | +0x7d0 | -> -1 |
| -78 | +0x942 | -> -1 |

initfn: AllocMem(24,MEMF_PUBLIC|CLEAR), OpenLibrary dos/37 +
utility/36. Close-underflow -> deferred expunge quirk reproduced.
