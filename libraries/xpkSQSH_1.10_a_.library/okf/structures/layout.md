# xpkSQSH 1.10(a) — layouts

Stream format, workspace, XpkSubParams offsets and private-data
layout identical to xpkSQSH_1.00 — see
`libraries/xpkSQSH_1.00.library/okf/structures/layout.md` (descriptor
constants verified identical: PackMem 0x22080, PackSpeed 25,
UnpackSpeed 300, Ratio 424, ChunkSize 32, DefMode 100, flags 0x2009).

## File structure

| range | content |
|-------|---------|
| 0x000–0x023 | HUNK_HEADER (1 hunk) |
| 0x024–0x3d3 | code: romtag/InitTable/vectors/lifecycle/wrappers — matches 1.00 modulo shifted entry points |
| 0x3d4–0x785 | code: new encoder core (~0x3d8) + 020 entry decoder head (0x762) |
| 0x786–0xb17 | code: btst-loop decoder body (the fragment orphaned in xpkSQSH_1.10) + tables |
| 0xb18+ | HUNK_RELOC32 + HUNK_END |

## Encoder/decoder structural deltas vs 1.00

- No bitfield instructions anywhere — all bit I/O is unrolled
  `btst`-loop code (68000-compatible).
- Cost arithmetic uses `divu.w`/`mulu.w`.
- Decoder entry at 0x762 keeps the 020-style structure for the first
  decisions then flows into the btst region for the ladder/field
  fetches; litpress semantics (`cmpw #31` cap, `>7` inversion)
  identical.
- Emit tables re-tailored; the widtab-like table sits at ~0xada
  (file 0xafe).
