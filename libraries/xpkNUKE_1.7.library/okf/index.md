# xpkNUKE_1.7.library — OKF index

- Binary: `binary/xpkNUKE_1.7.library` (2,900 bytes, md5
  `d644cfccffa44a284bc6e4050e2f2029`).  **Two hunks**: a 3E9 code
  hunk of 0x27d longs (0x9f4 bytes, body at file+0x24) and a 3EA
  data hunk of 0x21 longs (0x84 bytes, body at file+0xa94).
- Identity: `xpkNUKE 1.7 (06.06.1997)` — note: *no* `$VER:` cookie,
  the id string goes straight to the name+version.  lib type 9
  (NT_LIBRARY), flags 0x06, version 1, revision 7.
- Kind: XPK sublibrary — packer + unpacker, one pack mode "normal".
  Ten vectors, standard xpk sublib shape (open/close/expunge/null +
  XpksPackerInfo/PackChunk/PackFree/null/UnpackChunk/null).
- CPU: plain 68000; no AttnFlags gate in LibInit.
- **Generation**: this is the *older* skeleton, not the 1.8/1.9 one:
  - absolute-address functab (10 longs + `0xffffffff`), not the
    generated two-pass word-offset table used by 1.8+;
  - InitTable + datatab embedded in the code hunk
    (InitTable at code+0x1e, datatab at code+0x5a, functab at
    code+0x2e);
  - the runtime seglist is stored in a code-segment slot
    (`code+0x7a`), not in lib+38;
  - `rt_EndSkip` = 0x106, pointing at the `rts` of the dedicated
    -24 null stub at code+0x104;
  - packer workmem is THREE separate AllocMems (92-byte cleared
    header + 0x20000 tab1 + 0x10000 tab2), not the single 196,700-byte
    arena of 1.9;
  - the mode descriptor and XpkInfo live in the **data hunk**
    (hunk1+0 / hunk1+0x2a) — code hunk only holds the strings.
- Codec: identical algorithm family to 1.9 — pair-hash chain LZ77,
  window 0x6a8f, four interleaved output streams, backward literal
  block.  1.7-specific details vs 1.9: the window-edge discard test
  is the *same* `bls` (`d6 <= d4`, incl. the d6==0 sentinel case),
  and the tail-copy overflow test fails only when outcur passes
  litptr strictly.
- Reconstruction: `source/xpkNUKE.c` (pack/unpack cores + wrappers),
  `source/xpkNUKE_lib.s` (RomTag, InitTable, datatab, absolute
  functab, lifecycle asm), `source/Makefile` (`-m68000`, NDK).
- Oracle: `work/oracle.py` (machine68k) — lifecycle, PackerInfo
  descriptor, 20-corpus pack streams **byte-identical** to the
  original, unpack round-trips, PackFree/realloc, alloc-failure and
  tiny-outbuf error paths.  See `work/oracle_orig.log` /
  `work/oracle_re.log` (only vector addresses and code-relative
  string pointers differ, as expected).

## Layout of this bundle

- `structures/layout.md` — lib base, InitTable/datatab, data hunk,
  pack workspace map
- `functions/vectors.md` — vector map, entry/exit behaviour per LVO
- `algorithms/codec.md` — NUKE stream format, hash chains, emit order
- `findings/defects.md` — original defects/limitations reproduced
- `log.md` — chronological work log
