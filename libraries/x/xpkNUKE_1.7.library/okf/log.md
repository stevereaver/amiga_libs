# xpkNUKE_1.7.library — work log

## Hunk parsing and identity

- Parsed Amiga hunk structure: HUNK_HEADER, two hunks —
  code `0x27d` longs at file+0x24, data `0x21` longs at file+0xa94.
  Relocs: hunk0 {21->h0, 1->h1}, hunk1 {7->h0, 1->h1}.
- Established this is the *older* (1.16-era) skeleton: absolute
  functab, InitTable/datatab in the code hunk, seglist stored in a
  code slot at code+0x7a, rt_EndSkip = 0x106 = rts of the dedicated
  -24 null stub at 0x104 (separate from the shared 0x134 stub used
  by InitFn and the -48/-60 vectors).

## Code map from disassembly

- RomTag at code+4, InitTable at code+0x1e, functab at code+0x2e
  (10 absolute longs + ffffffff), datatab at code+0x5a.
- Lifecycle: Open 0x9e / Close 0xac / Expunge 0xc0 (deferred-expunge
  via flags bit 3 at lib+14, Remove+FreeMem through the code-slot
  seglist).
- Codec: flush_lit 0x200, pack_core 0x2fa, pack_init 0x60e,
  pack_finish 0x696, pack_tail 0x6fa, decoder 0x73c, PackerInfo 0x848,
  PackFree 0x8b6, pack_alloc 0x902, PackChunk 0x952,
  UnpackChunk 0x9c6, backward memset 0x9e8.
- Data hunk: XpkMode "normal" at +0, XpkInfo at +0x2a (strings point
  back into the code hunk).

## Source reconstruction

- `source/xpkNUKE.c`: pack/unpack cores and the xsp wrappers,
  `struct Work` matching the 92-byte header layout; split allocs
  (92 + 0x20000 + 0x10000).
- `source/xpkNUKE_lib.s`: hand-written 1.7 skeleton — RomTag with
  EndSkip->0x106 semantics via a separate `_libnull24` stub,
  absolute `_functab`, InitTable, datatab, code-slot seglist.
- First build produced an oversized code hunk (0x418 vs 0x27d
  longs) — acceptable since the oracle compares *behaviour*;
  vector ORDER and all semantics verified identical.  Current build
  hunk0 = 0x419 longs.

## Oracle bring-up

- `work/oracle.py` (machine68k): parses both hunks, applies
  cross-hunk relocs, emulates MakeLibrary/InitStruct (absolute
  functab), stubs AllocMem/FreeMem/Remove; exercises lifecycle,
  PackerInfo, 20-input pack corpus + unpack round-trips, PackFree,
  realloc, tiny-outbuf and (out-of-line) alloc-failure paths.

## Divergence hunt (ramp/txt/rnd8k)

- First trap harness corrupted the run (replacing the 4-byte
  `movew a4@(40),d7` without setting flags broke the following
  `blts`).  Fixed by emulating instruction+branch and redirecting
  pc — see `work/trace_emit.py`.
- Faithful emit traces then showed ONE semantic difference: at the
  window edge the original uses `cmp.w d4,d6; bls` — discard a
  *better* match and stop when the candidate is at/below the window
  edge (incl. the d6=0 chain sentinel).  The reconstruction used
  `<`, which let position-0 matches win (e.g. `ramp` pos 767:
  emitted len3/off767 instead of len1/off1).  Also fixed the
  lazy-clear edge to `d5 > window` (BLS skipped at equality).
- After the fix: all 20 corpus streams byte-identical, all
  round-trips identical (incl. the `z40k` inherited failure),
  PackFree returns 0x5c, alloc-failure frees match.

## Verification summary

- oracle_orig.log vs oracle_re.log differ ONLY in vector addresses
  and code-relative string pointers inside the dumped XpkInfo —
  expected since the rebuilt code hunk is larger.
- No commits made; all changes confined to
  `libraries/xpkNUKE_1.7.library/`.
