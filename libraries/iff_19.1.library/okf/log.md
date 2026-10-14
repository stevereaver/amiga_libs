# iff.library 19.1 — reconstruction work log

## Approach

1. `m68k-amigaos-objdump -D -b binary -m m68k` over the
   whole binary → `work/full.asm` (file offsets; code =
   file − 0x20).
2. Decoded the HUNK_HEADER/CODE wrapper, RomTag
   (matchtag/endskip/name/id/init pointers), InitTable and
   the 16-entry absolute functab by hand.
3. Used the verified iff_16.4 reconstruction
   (`../iff_16.4.library/{source,work,okf}`) as the
   template; diffed every function against the 16.4
   disassembly and its documented quirks.
4. Rebuilt `source/iff_lib.s` (resident + lifecycle asm),
   `source/iff.c` (API), `source/Makefile`; compiled with
   `m68k-amigaos-gcc -O2 -m68000 -fomit-frame-pointer
   -nostdlib`.
5. Adapted `work/oracle.py` (machine68k, M68020) — emulated
   MakeLibrary/InitStruct incl. the 8-bit-offset datatab
   forms — plus `work/build_iff.py` fixtures.
6. Ran the same oracle script against `binary/iff_19.1.library`
   and `source/iff.library`; diffed the logs.

## Resolved details

- The original's datatab uses the **short** InitStruct
  forms ($a0/byte, $90/word, $80/long) with byte entries
  padded to even — the first rebuild missed the pad bytes
  and the InitStruct parse misaligned.  Fixed; initfn now
  lands at +0x108 exactly like the original.
- `findnode`/`clrerr`/`seterr` are shared asm helpers at
  +0x7ec/+0x808/+0x814 — ThisTask read direct from
  SysBase+276; clrerr returns 1, seterr writes d0→node+18
  and returns 0.
- LibOpen/Close/Expunge matched the original
  instruction-for-instruction (moveml masks, bclr/bset #3
  on lib_Flags, FreeMem(neg+pos)).
- DecodeAnim's column decoder is Duff-unrolled ×8
  (`asrw #3` outer + `(cnt&7)*4` jump-in); reconstructed as
  a plain loop — semantics identical, oracle-verified.
- ANIM fixture bug found during testing: op `0xFE` is 126
  literals (`op&0x7f`), not 2 — the spec's "-n" phrasing is
  misleading; documented as a quirk.

## Oracle coverage

All 16 vectors exercised through real structures:
- init/MakeLibrary + datatab init (type/flags/ver/rev/name/id)
- LibOpen ×2 (dup rejection), opencnt, node list
- OpenIFF: ILBM raw, RLE (0x80 NOP), 3-plane→shallow-bm,
  8SVX (CHIP attr via autodetect), missing file (16),
  non-FORM (19), short FORM (accepted)
- NewOpenIFF with explicit memattr
- FindChunk(BODY), FindChunk(0) = end
- GetBMHD, GetColorTab (4 masked colors), missing CMAP → 0
- GetViewModes: CAMG 0xf10f → 0x900d (mask verified)
- DecodePic: raw, RLE, extra-planes→scratch, shallow bm
- DecodeAnim: op-5 rep/literal/skip ops, zero-offset plane,
  op≠5 (28), no ANHD (29), no DLTA (30), non-ILBM (24)
- DecodePic errors: no BMHD (25), no BODY (26), comp>1 (28),
  non-ILBM (24)
- IFFError read+clear (second call → 0)
- SaveBitMap raw + crunch (file bytes compared)
- SaveClip raw, byte-window clip (BMHD left/top verified)
- LibExpunge while open → flag 0x0e; final close → seglist;
  Remove/CloseLibrary/FreeMem call sequence compared

## Result

`diff work/orig.log work/rebuild.log` — **empty**.
Return values, error codes, decoded plane bytes, saved file
bytes, alloc/free/remove/close order and sizes, deferred
expunge behaviour: all identical.

The rebuilt binary is larger (~5.8KB vs 2716B) — the modern
compiler's codegen differs (register allocation, no shared
findnode tail, unrolled stores compiled differently) — but
the reconstruction is behaviourally equivalent on every
path the oracle can reach, including the memory layout of
library private data and per-task nodes.
