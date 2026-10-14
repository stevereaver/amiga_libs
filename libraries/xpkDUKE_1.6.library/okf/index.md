# xpkDUKE.library 1.6 — reverse engineering index

XPK compression sublibrary, "Duke" by Christian von Roques
(08.06.1997). Per its own descriptor: **"NUKE with a delta
preprocessor"** — an LZ77 cruncher (same stream format as xpkNUKE
and the later DUKE 1.8(000)) wrapped in a byte-delta transform.

This is the **1.x-generation** of the library and differs strongly
from the reconstructed 1.8(000): two hunks (CODE+DATA) with RELOC32
relocations, a longword-pointer functab, a bare 34-byte `struct
Library`, a self-modifying seglist cell in the code hunk, and a
four-block memory plan (92B header + 0x20000 + 0x10000 tables +
0x8000 scratch shared between the pack delta pass and the unpack
decode/integrate stage).

## Files

- `binary/xpkDUKE_1.6.library` — original, 3280-byte file:
  HUNK_HEADER (2 hunks), CODE hunk 0x2dc longs = 2928 bytes,
  DATA hunk 0x21 longs = 132 bytes, RELOC32 tables, no BSS.
- `source/` — behavioral reconstruction:
  - `xpkDUKE.c` — codec core + 1.6 driver layer
    (delta pre/post, split allocs, free routines)
  - `xpkDUKE_lib.s` — entry stub, RomTag, longword functab,
    datatab, in-code seglist cell, lifecycle, strings + the
    `.data` descriptors (XpkMode/XpkInfo)
  - `Makefile` — single-pass build (longword functab needs no
    offset measurement)
  - built artifact: `source/xpkDUKE.library`
- `work/` — `hunk0.bin`/`hunk1.bin` extracted bodies,
  `hunk0.dis` disassembly, `oracle.py` (machine68k oracle),
  `difftest.py` (randomized differential), `streamsO/` original
  streams, `streamsR/` rebuild streams (all 20 byte-identical),
  `orc_orig.log`/`orc_rebuild.log`, `res_{a,b}.pkl`.

## Result

20 corpus + 160 randomized differential inputs: pack output
byte-identical, return codes identical, unpack round-trips
identical, alloc/free/lifecycle traces identical. See `log.md`
and `findings/quirks.md`.

## Contents

- `functions/vectors.md` — vector/LVO map and lifecycle behavior
- `structures/layout.md` — hunk map, RomTag, XpkSubParams,
  workspace, descriptors
- `algorithms/codec.md` — delta layer + NUKE stream format
- `findings/quirks.md` — bugs and quirks (all preserved)
- `log.md` — verification log
