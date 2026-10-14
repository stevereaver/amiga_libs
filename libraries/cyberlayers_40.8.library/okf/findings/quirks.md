# cyberlayers.library 40.8 — quirks & inconsistencies

- **Cache table overruns the library allocation.** The SwapBits cache
  (`30 x {bitmap,buffer}`) lives at cyberlayers+58 but the InitTable
  `dataSize` is only 0x76 (118 B positive). The table spans +58..+298 —
  180 bytes past the end of the allocated library structure into
  whatever follows the base in memory. Latent corruption; only the
  non-native-bitmap cache path touches it.

- **Unbalanced fail path in initfn.** If `OpenLibrary("cybergraphics",
  40)` fails, `beqw` jumps straight to the trailing `rts`, skipping the
  `moveml sp@+,d1/a5` restore — the `rts` pops the saved a5 value and
  "returns" to whatever was in the caller's a5 rather than the real
  return address. In the oracle a5 was pointed at the exit trap to
  observe the path cleanly; on a real system this is almost certainly
  a crash (or a return into exec's leftover a5).

- **Packed Resident clone.** _initctx copies the layers.library
  Resident assuming the *packed* 26-byte layout (matchtag@2,
  endskip@6, name@14, idstr@18, init@22) — not the standard padded
  32-byte `struct Resident` — and rewrites four interior pointers
  inside the copied init area (@init+4/+8/+12/+40, i.e. the copy's
  InitTable triple plus one pointer 0x28 in). It then renames the clone
  "layersdummy.library" and InitResident()s it with seglist 0.

- **`jsr pc@(d16)` surgical rewrite.** Before re-pointing the vectors,
  the code scans the clone for `4eba` (`jsr pc@(d16)`) instructions
  whose pc-relative target equals the clone's -126 jump-table target,
  and patches them to `4eae ff82` (`jsr a6@(-126)`) — rerouting
  layers' internal calls to SwapBits through the vector so they hit
  the cyberlayers hook. Scan failure silently abandons the repoint
  (CloseLibrary, no SetFunctions).

- **Full jump-table transplant.** All 32 public layers vectors
  (-30..-216 = InitLayers..DoHookClipRects) are SetFunction'd to the
  *clone's* targets — so layers.library runs the layersdummy
  implementation; the six cyberlayers hooks are then installed on top
  and their CYBL+0xe "old vector" slots therefore point into the
  clone, not the ROM implementation. The -222..-240 V45 vectors are
  left untouched.

- **Dead code @h0+0x5b2.** `_sbdead` (an earlier variant of the
  SwapBits fast path combining the engine alloc/convert calls with the
  cgx -84 call) has no incoming branches — `_cybfn` ends with `rts`
  right before it and nothing jumps in.

- **`movemw` single-register stack traffic.** MoveSizeLayer does
  `48a7 8000`/`4c9f 0001` — word-sized moveml push/pop of d0 — to
  save/restore the flags word around the SMART test.

- **`b07c` non-cmpi compare.** `cmpw #0x4eba,d0` and `cmpw #2,d0`
  assemble as `b07c` (CMP.W #imm,Dn), not `0c40` (CMPI) — gas wants
  the latter, so both are emitted as raw `.short` words.

- **Explicit zero displacements.** `a2@(0)`, `a1@(0)`, `sp@(0..8)`
  forms appear throughout hunk1 (`202a 0000`, `4aa9 0000`, `b1e9
  0000`, `3f68 xxxx 000y` …); gas elides the zero, so all are raw
  `.short` emits.

- **Mixed abs.w/abs.l SysBase loads.** `moveal 4:w,a6` (`2c78`) in
  _initctx/_patchinstall but `moveal 4:l,a6` (`2c79 0000 0004`) in
  Expunge — two encodings of the same read, preserved verbatim.

- **Hook=1 sentinel == LAYERS_NOBACKFILL.** The CUHL hook calls
  CreateBehindHookLayer with `lea 1:w,a3` ((Hook*)1 =
  LAYERS_NOBACKFILL) to suppress backfill during creation, then later
  `cmpal #1,a3` skips the DoHookClipRects initial backfill when the
  caller's own hook was also the sentinel.

- **Layer flag laundering.** Both the CUHL hook (forces SIMPLE during
  CreateBehindHookLayer, restores type bits afterwards) and the
  MoveSizeLayer hook (temporarily flips SMART->SIMPLE around the orig
  call) borrow the type bits to bypass SMART-refresh bookkeeping.

- **RELOC32SHORT.** Hunk0's relocations use the compact word-offset
  form (0x3f7) with the original group order h0->h0 then h0->h1; GNU
  ld emits only RELOC32, so `fixup.py` rewrites the entire file and
  byte-verifies against the original.
