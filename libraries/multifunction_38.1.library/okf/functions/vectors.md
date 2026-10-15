# Vectors (31, absolute long, LVO -6..-186)

| LVO | Target | Notes |
|-----|--------|-------|
| -6   | h0+0x148 | Open |
| -12  | h0+0x174 | Close |
| -18  | h0+0x188 | Expunge |
| -24  | h0+0x1ca | -> 0 |
| -30  | h0+0x1ce | -> 0 |
| -36  | h0+0x242 | -> 1 |
| -42  | h0+0x26c | list Remove x2 |
| -48  | h0+0x32e | -> h0+0x3xx ptr after Remove |
| -54  | h0+0x422 | -> 0 |
| -60  | h0+0x460 | Remove x3 -> 0x50 |
| -66  | h0+0xa60 | -> 0x31 |
| -72..-186 | h0+0xbb0..0x10b4 | 21 further entry points (bitmap/pen ops; under stub args most return 0xf7) |

All vectors verified to execute; traces deterministic and identical
between original and reconstruction.
