# xpkNUKE 1.7 — vector map

Absolute-long function table at code+0x2e, `-1` terminated.

| LVO | name | notes |
|-----|------|-------|
| -6  | Open | opencnt++ |
| -12 | Close | opencnt--; deferred expunge |
| -18 | Expunge | Remove + FreeMem |
| -24 | LibNull24 | own stub |
| -30 | XpksPackerInfo | `lea` of XpkInfo descriptor in DATA hunk |
| -36 | XpksPackChunk | wrapper: allocs 3 workmems (92B hdr + 0x20000 tab1 + 0x10000 tab2), memsets tables, calls pack core |
| -42 | XpksPackFree | frees the three workmems |
| -48 | LibNull | stub |

## Codec

LZ77 cruncher, same as xpkNUKE 1.9:

- pair-hash chain window 0x6a8f; positions are 1-based file indices
- four interleaved output streams in consumption order:
  1. word accum MSB-first — token flags (1=match, 0+1=lit, 0+0=litrun)
  2. word accum 2-bit — literal-run counts + class 10-15 len ext
  3. long accum nibbles — offset-class code + long-match len ext
  4. long accum MSB-first — offset residual bits
- literals written BACKWARD from outbuf+outbuflen-4, appended after
  streams, 0xfb-padded to long alignment
- decoder dispatches via `jmp pc@(tab,d0:w)` jump tables (1.9 uses
  compare chains)
