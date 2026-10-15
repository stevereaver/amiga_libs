---
file: vectors
---
# Vectors

18 jmp slots @h0+0x24 .. +0x8a (lib base = h0+0x90; LVO -6 -> slot
@+0x8a ... LVO -108 -> slot @+0x24):

| LVO | target | role |
|-----|--------|------|
| -6   | +0xf0/0xec | Open — OpenCnt++ at base+0x20, clr expunge-flag |
| -12  | +0xfa   | Close — OpenCnt--, deferred-expunge flag |
| -18  | +0x110  | Expunge — RemLibrary + CloseLibrary(dos) |
| -24  | +0x110/0x118 | reserved |
| -30  | +0x6c2  | (returns 4 — version/tag query?) |
| -36  | +0x846  | |
| -42  | +0x7d8  | (returns 'NAME' — reads a name ptr) |
| -48  | +0x70c  | |
| -54  | +0x76c  | |
| -60  | +0x798  | |
| -66  | +0x250  | |
| -72  | +0x13a  | (returns 8) |
| -78  | +0x594  | |
| -84  | +0x5a4  | |
| -90  | +0x2b4  | |
| -96  | +0x5fe  | |
| -102 | +0xa34  | |
| -108 | +0x0    | (returns 0 — null/stub slot) |

initfn deps: dos.library only.
