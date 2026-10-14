# cyberlayers.library 40.8 — work log

## Phase 1 — hunk & disassembly recon

- `work/analyze_hunks.py`: hunk walk -> CODE h0 0x844 B, h1 0x29c B;
  h0 relocs are RELOC32SHORT (w-words) in two groups: h0->h0
  {0x6,0x12,0x16,0x1a,0xc6,0xca,0xce,0xe4,0xf6,0x4ac} then h0->h1
  {0xa,0x48e,0x494,0x49a,0x4a0,0x4a6}. h1 clean.
- Extracted hunk bodies to `work/orig_h0.bin`/`orig_h1.bin`; linear
  objdump + hand analysis. Identified: packed RomTag @h0+4
  (endskip->h1+0x29c=EOF), strings, InitTable@0xc2 (dsize 0x76,
  word-offset functab@0xd2 -> Open/Close/Expunge/ExtFunc
  @0x4b2/0x4c0/0x4d4/0x51a), initfn@0xfe, the layers-Resident cloning
  block @0x152, SetFunction walker @0x454 + patchtab@0x48c, six CYBL
  records + patched functions (SwapBits in h0, five layers hooks in
  h1), and the h1+0x26e rect-overlap helper.
- Semantics: CyberGraphX layers accelerator — clones layers into
  "layersdummy.library", transplants all 32 vectors, rewrites clone
  `jsr pc@(-126 target)` -> `jsr a6@(-126)`, hooks
  -36/-186/-60/-66/-180/-126.

## Phase 2 — assembly reconstruction

- `source/cyberlayers_h0.s`, `source/cyberlayers_h1.s` rewritten by
  hand; `source/Makefile` (m68k-amigaos-gcc, two input sections,
  generated `hunks.x` ordering h0 then h1) + `source/fixup.py`
  (rewrites GNU ld output: reorders into h0/h1/reloc/h0relocs/end and
  emits RELOC32SHORT; diffs every long against the original).
- Fixups needed for byte identity (all as `.short` raw emits):
  `b07c` non-cmpi compares; explicit zero displacements (`4aa9 0000`,
  `b1e9 0000`, `202a 0000`, `3f68 xxxx 000y`, `b269 0000`,
  `3228 0000`); `2c79 00000004` abs.l moveal; `203c ...` immediate
  moves; `4cdf` pop masks; `b27c/927c/1f3c` non-quick forms; the
  4-byte `bsr.b` at h0+0x4a8 emitted as `bsrw + .short` trick.
- Fixup bug: first fixup.py packed 7 fields with a 6-field struct
  format — corrected to `'>IIIIIII'`.
- Result: **byte-identical** — md5
  `51ee1a5be1b9c2af4cf7740c3b91d591` for both
  `binary/cyberlayers_40.8.library` and `source/cyberlayers.library`.

## Phase 3 — runtime oracle

- `work/oracle.py` (machine68k): loads both hunks, applies
  RELOC32SHORT; fake exec (FindResident/InitResident/SetFunction/
  AllocVec/CopyMem/InitStruct path via real InitResident/OpenLibrary/
  CloseLibrary/Remove/FreeMem…), packed fake layers Resident, fake
  layersdummy base with jmp table + a `4eba` self-call site for the
  rewrite scan, graphics/cybergraphics bases, and a `*(layers+34)`
  engine base with -30/-918/-924.
- Exercises: full init (30 vector repoints + 6 CYBL installs), CUL/
  CUHL (NULL/sentinel/SUPER/normal paths), ML/SL/MSL (degenerate,
  noop, non-smart tailcall, fast, lobs-obscured, front-overlap),
  SwapBits (orig, cache miss+hit, native-'CYBR', 68020 path,
  fallback), Open/Close/Expunge incl. deferred expunge, no-cgx abort
  and exec<39 early-exit.
- Bugs hit along the way: Machine RAM arg overflow; negative regs
  need `&0xffffffff` on w_reg; alloc-heap colliding with hunk1
  (moved to 0x80000); `jsr pc@` target out of d16 range (dummy stubs
  at 0x7c000); walrus-in-kwarg syntax; overlap test needed non-zero
  deltas (0-delta hits the MSL noop path).
- Result: `orig.log == new.log` — `=== ORACLE IDENTICAL ===`.
