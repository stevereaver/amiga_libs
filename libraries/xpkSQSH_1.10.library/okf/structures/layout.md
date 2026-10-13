# xpkSQSH 1.10 — layouts

Loadable image is byte-identical to `xpksqsh_1.10(older)` (=
xpkSQSH_1.00 code + 1.10 metadata). Stream format, workspace,
XpkSubParams and private-data layouts: see
`libraries/xpkSQSH_1.00.library/okf/structures/layout.md` and
`libraries/xpksqsh_1.10_older_.library/okf/structures/layout.md`.

## File structure

| range | content |
|-------|---------|
| 0x000–0x023 | HUNK_HEADER (1 hunk declared) |
| 0x024–0x857 | HUNK_CODE, 525 longs = 2100 bytes |
| 0x858–0x8b7 | HUNK_RELOC32 (22 offsets, all < 0xa0) + HUNK_END |
| 0x8b8–0xb77 | **overlay**: 704 bytes, dead to the loader |

## Overlay map (offsets file-relative)

- 0x8b8: bit-reader prologue + a 5-iteration outer run loop
  (`moveq #4,d5`/`dbf d5`)
- 0x8bc–0x952: unrolled MSB-first `btst` bit fetches — a ladder
  selecting d4 ∈ {2,4,6} then 3/5-bit fields + 8/16 → a width/slot
  selector analogous to the hunk decoder's inverted ladder, but with
  different constants (this is NOT the same token ladder — likely a
  different SQSH build's decoder)
- 0x916: inner loop head (`braw 0x916` at 0xad6 = loop back)
- 0xa12–0xad8: field fetch + len adjustment + `lea a1@(x,a5:w)` dist
  computation + dbf copy loop (`moveb a4@+,a1@+`) + litpress tail
  (`cmpw #31` clamp at 0x90e)
- 0xada–0xb11: data table, looks like a widtab variant
  (`02 03 04 05 06 07 08 00 ...`)
- 0xb12–0xb77: zeros + a second reloc-looking block (`03ec` =
  HUNK_RELOC32 + 20 offsets) — the tail of whatever hunk this fragment
  was cut from

All branches are position-relative; one `bltw` at file 0x91e targets
file 0x7b6 — inside THIS file's hunk decoder — consistent with the
fragment having been assembled contiguously against a similar-prefix
build, but nothing in the loadable image branches into the overlay.
