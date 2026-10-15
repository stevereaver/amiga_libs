---
type: Functions
title: bfbplaymaster 1.0 vector map
---

# Vector map (functab h0+0x484, 19 absolute longs)

| LVO | target | observed (stub env) |
|-----|--------|---------------------|
| -6   | 0x516 | Open |
| -12  | 0x524 | Close |
| -18  | 0x538 | Expunge |
| -24  | 0x592 | reserved |
| -30  | 0x596 | 0xffffffef |
| -36  | 0x696 | 0xffffffef |
| -42  | 0x6fa | 0x80 |
| -48  | 0x738 | 0xffffffef |
| -54  | 0x7f8 | 0xfffffffe |
| -60  | 0x83a | 0x80 |
| -66  | 0x88a | 0xfffffffe |
| -72  | 0x8cc | 0x0 |
| -78  | 0x90e | 0x80 |
| -84  | 0x954 | 0x0 |
| -90  | 0x996 | 0xfffffffe |
| -96  | 0x9e0 | 0x0 |
| -102 | 0xa02 | 0x50b1b (error-string ptr?) |
| -108 | 0xace | 0x22 |
| -114 | 0xb98+? | 0x0 |

User vectors return small error codes (-0x11, -2, 0x80) under
stubs — the lib gates on taglists/sub-lib availability.
