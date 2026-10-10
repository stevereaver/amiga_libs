# Functions

| LVO  | vector | original hunk0 offset |
|------|--------|-----------------------|
| -6   | [LibOpen](LibOpen.md)     | 0xda  |
| -12  | [LibClose](LibClose.md)   | 0x1f4 |
| -18  | [LibExpunge](LibExpunge.md) | 0x25e |
| -24  | entry stub (returns 0)    | 0x00  |
| -30  | [PTBeep](PTBeep.md)       | 0x33c |

Internal: LibInit @0x20, per-open init @0x2d0 (OpenLibrary),
per-open cleanup @0x314 (CloseLibrary).
