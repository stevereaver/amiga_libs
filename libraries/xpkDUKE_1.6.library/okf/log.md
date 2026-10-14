# Work / verification log

## Static analysis

1. Parsed hunk header: magic `0x3f3`, **two** hunks — CODE `0x3e9`
   (0x2dc longs = 2928 bytes, body at file offset 0x24) and DATA
   `0x3ea` (0x21 longs = 132 bytes), each followed by HUNK_RELOC32
   (21 hunk0 + 1 hunk1 refs on code; 7 hunk0 + 1 hunk1 refs on data)
   and HUNK_END. File is 3280 bytes.
2. Disassembled `work/hunk0.bin` with `m68k-amigaos-objdump -D
   -b binary -m m68k` → `work/hunk0.dis`.
3. Parsed RomTag (code+4), InitTable (code+0x1e, dataSize 0x22),
   longword functab (code+0x2e, 10 vectors + -1), datatab
   (code+0x5a), strings, and the descriptors in the DATA hunk
   (XpkMode @+0, pad word @+0x28, XpkInfo @+0x2a).
4. Established the in-code seglist cell at code+0x7a: LibInit's
   `move.l a0,$7a` operand carries a RELOC32 (@0x84) so it stores
   to code+0x7a; Expunge's `move.l pc@(…),d2` reads the same cell.
5. Verified the `341d` at 0x7ca/0x7d4 is `move.w (a5)+,d2` (flag
   stream reload) and `361d` at 0x7ac/0x7ee is `(a5)+,d3`
   (2-bit stream) — bit-barrel semantics identical to 1.8's
   decoder.

## Codec comparison vs DUKE 1.8(000)

- Pack core, decode loop, tables: same algorithm and same table
  values; different absolute placement and minor codegen deltas
  (e.g. `movew #0x6a90; subqw #1` for the window constant, a
  stack-arg calling convention for the helper subs).
- Driver layer differs entirely: four AllocMem blocks
  (92 CLEAR + 0x20000 + 0x10000 + 0x8000 ANY) vs one 0x3758c arena;
  Duff-device delta/integrate loops vs dbf loops; PackFree frees
  everything and clears both Sub pointers; real -60 UnpackFree.
- Same `bls` success gate (outlen ≤ inlen → 0).
- No 1.8 quirks here: no stale Sub[0], no wrong free size, no
  delta/post-pass overruns, no `$VER:` idstring, rt_EndSkip nonzero.

## Reconstruction

- `source/xpkDUKE_lib.s`: entry stub (-1), RomTag
  (rt_EndSkip→_endscan, the -24 stub's rts), InitTable (dataSize
  0x22), longword functab, datatab, `_segcell` at the equivalent
  gap offset, LibInit/Open/Close/Expunge transcribed (incl. dead
  `bsr _LibNull` calls), strings, PackerInfo; `.data` section
  carries XpkMode + pad + XpkInfo (second hunk, like the original).
- `source/xpkDUKE.c`: pack/decode cores ported verbatim from the
  proven DUKE 1.8 C (same Work field map), plus 1.6 drivers:
  alloc_work (4 allocs + PackFree cleanup), delta_encode/integrate
  (plain loops — the Duff unrolling is output-invisible),
  PackChunk (strict-ish `<=` gate, OutLen stored first), PackFree,
  UnpackChunk (lazy scratch + decode→scratch→integrate),
  UnpackFree.
- Built with `/opt/amiga/bin/m68k-amigaos-gcc -O2 -m68000
  -nostdlib -nostartfiles` → `source/xpkDUKE.library`
  (2 hunks; code 0x469 longs — larger than the original, GCC
  codegen differs; DATA hunk is exactly 0x21 longs like the
  original). Functional equivalence is the criterion.

## Oracle runs (machine68k)

- `work/oracle.py` (adapted from the 1.8 harness): loads hunks,
  emulates MakeLibrary/InitStruct, stubs AllocMem/FreeMem/Remove,
  exercises all 10 vectors including -60 UnpackFree.
- `streamsO/` (original) vs `streamsR/` (rebuild): all 20 corpus
  streams byte-identical; rc/outlen/unpack-match lines identical;
  lifecycle trace identical (deferred expunge → Remove +
  FreeMem(128), seglist returned from the in-code cell);
  PackerInfo descriptor field-identical; UnpackFree →
  `freemem(…,0x8000)` + cleared Sub[1] and no-op second call;
  PackFree → `freemem`×4 (0x8000, 0x20000, 0x10000, 92) + cleared
  pointers, returns 0x5c; realloc-after-PackFree performs a fresh
  4-block alloc on both; tiny-outbuf → -17 with OutLen=0xffffffff.
- Randomized differential (`work/difftest.py`, separate processes,
  `res_{a,b}.pkl`): 160 cases — random/uniform-4/ab/mod-17/
  short-periodic/zeros across sizes 0..30000 — **0 mismatches**
  in streams, return codes, or round-trip verdicts.
