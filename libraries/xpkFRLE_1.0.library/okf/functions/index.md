---
type: Index
title: xpkFRLE 1.0 functions
---

# Functions

Function table: word-offset AUTOINIT table (leading -1 marker,
offsets relative to the marker word, trailing -1).

| LVO  | Function          | Original addr | Notes                  |
|------|-------------------|---------------|------------------------|
| -6   | LibOpen           | 0xaa          |                        |
| -12  | LibClose          | 0xb8          |                        |
| -18  | LibExpunge        | 0xcc          |                        |
| -24  | ExtFunc           | 0x10a         | `moveq #0,d0; rts`     |
| -30  | XpksPackerInfo    | 0x10e         |                        |
| -36  | XpksPackChunk     | 0x116         | encoder                |
| -42  | XpksPackFree      | 0x10a         | null stub              |
| -48  | XpksPackReset     | 0x10a         | null stub              |
| -54  | XpksUnpackChunk   | 0x242         | decoder                |
| -60  | XpksUnpackFree    | 0x10a         | null stub              |
