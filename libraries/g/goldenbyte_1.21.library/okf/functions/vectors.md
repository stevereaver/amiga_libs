---
type: Functions
title: goldenbyte.library 1.21 vector map
---

# Vector map (functab h0+0x60, 25 absolute longs)

| LVO | target | | LVO | target |
|-----|--------|-|-----|--------|
| -6   | 0x0e2 Open | | -78  | 0x612 |
| -12  | 0x0ea Close | | -84  | 0x62e |
| -18  | 0x0f2 Expunge | | -90 | 0x694 |
| -24  | 0x18a reserved | | -96 | 0x6ee |
| -30  | 0x242 | | -102 | 0x702 |
| -36  | 0x34c | | -108 | 0x726 |
| -42  | 0x3c0 | | -114 | 0x75e |
| -48  | 0x3f4 | | -120 | 0x7e2 |
| -54  | 0x410 | | -126 | 0x9c8 |
| -60  | 0x4ac | | -132 | 0xb06 |
| -66  | 0x4f4 | | -138 | 0xb36 |
| -72  | 0x53c | | -144 | 0xb98 |
|      |      | | -150 | (vec 25 @0xb98) |

initfn opens 10 libs (intuition/graphics/dos/utility/workbench/
layers/reqtools/commodities/diskfont/icon).  User vectors call
exec -846-family and return handle/status values; -36/-42 return
0x74/0x80 etc under stubs.
