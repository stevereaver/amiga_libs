# Session log — xpkMASH 1.26

## Reverse engineering

- IRA disassembly of the 2044-byte single-hunk library; layout
  byte-for-byte parallel to V1.16 (same vectors, tables, emitter
  skeleton, decoder).
- Mnemonic-level diff vs 1.16 isolated the real deltas:
  - packentry: `alloc2` tries 5 sizes 0x20000..0x2000 (d5=5, shift
    derived as d5+3 => 8..4); V1.16 tried 8 down to 0x400.
  - `xsp_Bound = out + inlen - 10` (was -50).
  - pack core init: **no** 64KB chain fill — only
    `chain[in.w] = 0xffff`; head table still `filldown`-seeded
    with `in.w`.
  - bit emitter LAB_0055 gains a whole-byte path:
    `subq.w #8,d1 / bcs` test, `rol.l #8,d0`, `move.b d0,(a1)+` —
    emits a raw byte when >=8 field bits remain after a slot store.
    Semantically identical output, fewer bit loops.
  - decoder payload loops gain the mirror optimisation
    (`cmp.w #0xff00,d4` / `lsl.w #8` / `move.b (a0)+,d4`).
- Codec tables (runtab/rclass/lclass/distw/distor) byte-identical to
  V1.16 — token format unchanged; 1.26 packs decode with the 1.16
  decoder model.
- Descriptor: MaxPkInChunk 0x100000; strings "MASH V1.26, good
  packer", "WindowSize: 32KB, 2 mixed streams Dynamic Buffer
  Allocation"; mode record pspeed 17, uspeed 400, ratio 472,
  flags 1, tail 7ff8.

## Reconstruction

- Ported the corrected 1.16 C (post ULONG-width and len-2/carry
  fixes).  Same pctx/pack/unpack structure; changed init to
  chain-prime + head-seed, bound to -10, alloc2 retry table,
  added the emitter byte-path, updated descriptor + mode record.
- Skeleton reuses the 1.16 functab/init pattern; mode name field
  is 12 bytes (4-byte pad after ` -->    `) — verified against the
  original's record bytes (`7ff8` tail byte-exact).

## Test results (host harness, padded buffers)

- All compressible fixtures round-trip: zeros, ramps, text, periodic,
  tr46..tr90 boundary set (the -10 bound packs tr46/47/48 which 1.16
  rejected), sp* distance-boundary set, words, semi, rand4k.
- Faithful rejects (-17): sub-11-byte and incompressible inputs.
- distmax: nondeterministic — uninitialized chain + below-input
  window reads; passes or diffs at varying offsets run to run.
- big200k: packer HANGS — delta-0 chain self-loop past the 64KB
  low-word wrap (verified `D0LOOP at cur=132361 cand=131072`).
  Original defect, faithfully reproduced (see defects.md 4b).
  Not a reconstruction mismatch.
