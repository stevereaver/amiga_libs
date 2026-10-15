# cyberlayers.library 40.8 — vectors

Word-offset functab at h0+0xd2 (`0xffff` relative-format marker, then
4 offsets from the table base, `0xffff` terminator). All offsets are
hunk-relative. The library has **no public API** — its own vectors are
the four lifecycle entries; the real work is installing hooks into
layers.library.

## Own vectors (cyberlayers.library)

| LVO | h0 off | fn      | summary |
|-----|--------|---------|---------|
| -6  | 0x4b2  | Open    | lib_OpenCnt(+32)++, clears private DELEXP bit (bit3 of ln_Flags+14), returns a6 in d0. |
| -12 | 0x4c0  | Close   | OpenCnt--; if 0 && DELEXP bit set -> falls into Expunge; returns 0 (or seglist when expunging). |
| -18 | 0x4d4  | Expunge | If OpenCnt!=0: sets DELEXP bit, returns 0. Else: seglist=lib+38; Remove(a1=lib) via `moveal 4:l,a6`; FreeMem(lib-NegSize, Neg+PosSize); returns seglist. |
| -24 | 0x51a  | ExtFunc | `moveq #0,d0; rts` — also stored at lib+50 by initfn as a fallback pointer. |

## Patched layers.library vectors (installed by _patchinstall)

Each replacement sits behind an 18-byte `CYBL` record (see
structures/layout.md); +0xa receives the cyberlayers base, +0xe the
previous vector. Hook `a6` is the layers.library base.

| LVO  | hunk+off | fn | summary |
|------|----------|----|---------|
| -36  | h1+0x12  | CreateUpfrontLayer | pushes a3, a3=NULL hook, falls into the -186 body. |
| -186 | h1+0x2e  | CreateUpfrontHookLayer | if flags & LAYERSUPER(4): tail-call old vector. Else: LockLayerInfo, force LAYERSIMPLE (flags &= ~SMART, |= SIMPLE), call CreateBehindHookLayer(-192) with hook=LAYERS_NOBACKFILL((Hook*)1), UpfrontLayer(-48) it to the front, restore the caller's type bits into layer->Flags, store the real hook at layer+118, ClearRegion(layer+156) via graphics (-528), clear Flags&0x680, and unless hook==1 call DoHookClipRects(-216)(hook, layer->rp, NULL). UnlockLayerInfo(-138), return layer. Net effect: builds "upfront" layers through the behind-create path with refresh disabled during creation. |
| -60  | h1+0xe4  | MoveLayer | -> MoveSizeLayer(l, dx, dy, 0, 0). |
| -66  | h1+0x108 | SizeLayer | -> MoveSizeLayer(l, 0, 0, dx, dy). |
| -180 | h1+0x130 | MoveSizeLayer | If !(Flags&7)==LAYERSMART -> tail-call old vector. All-zero deltas -> return 1. Computes the post-move rect {bounds+dx,dy,dw,dh}; if degenerate (Max<Min) -> 0. LockLayerInfo(layer+68). Fast-path gate (d7): if layer != li+0, walk the layer's ClipRect chain — any cr->lobs(+8) != 0 (obscured cliprect) -> slow; then walk the front-layer chain (layer->front +0) testing each front layer's bounds(+16) against the new rect via _roverlap — any overlap -> slow. Fast: clear LAYERSMART bit, set LAYERSIMPLE in Flags+31, call old vector (which now treats the layer as SIMPLE — no damage-list refresh work), then restore the two bits. Slow: call old vector unchanged via a pea-return idiom. Both paths UnlockLayerInfo and return the orig result. |
| -126 | h0+0x530 | SwapBitsRastPortClipRect | rp=a0, cr=a1. If !(rp->BitMap+1 bit0): tail-call old vector. If !(cr->BitMap+1 bit0): cache path (below). Else if cr->BitMap+36 == 'CYBR' *or* SysBase AttnFlags bit3 (68020+, a2@(297)): cybergraphics -84(a0=rp->bm, a1=cr->bm, d0=cr.bounds.MinX, d1=.MinY, d2=MinX&15, d3=0, d4=w, d5=h, d6=2) — the native chunky swap. Else tail-call old vector. Cache path: 30-entry {bitmap,buffer} table at *(rec+0xa)+58 (cyberlayers base+58). Scan for cr->bm: HIT -> eng.-30(slotbuf -> rp->bm region), eng.-924(slotbuf), clear slot, rts. MISS -> find empty slot (evicting an old entry's buffer via eng.-924 if table full), _sb_alloc (eng.-918(w|15&~15? width+15&-16, h, 8, 16, rp->bm) -> buf, buf stored in slot+4, eng.-30(rp->bm -> buf)), _sb_fill (eng.-30(cr->bm region -> rp->bm with x&15 alignment, d6=0xc0, d7=-1)), slot bitmap = cr->bm. Alloc failure unwinds two frames and tail-calls orig. `eng` = *(a6+34) — a private "engine" base read from the *layers* base's first private field (allocs at -918, blit/convert at -30, frees at -924; exact names not in public FDs). |

## Internal helpers

| hunk+off | fn | summary |
|----------|----|---------|
| h0+0xfe  | initfn | AUTOINIT entry (d0=lib, a0=seglist, a6=exec). lib+34=exec, +38=seglist; OpenLibrary layers(39)->+42, graphics(39)->+46, cybergraphics(40)->+54 — on cgx fail: unbalanced `rts` quirk (returns into a5). lib+50=&ExtFunc. Calls _initctx, _patchinstall; returns lib. |
| h0+0x152 | _initctx | exec<39 -> bail. FindResident("layers.library") -> packed-resident copy (AllocVec(endskip-res), CopyMem, fix matchtag@2/endskip@6/name@14("layersdummy.library")/idstr@18/init@22 + 4 ptrs inside init area @+4/+8/+12/+40). InitResident(copy,0) -> a5 = layersdummy base. OpenLibrary("layers.library") -> a3. Scan copy for `4eba` (jsr pc@d16) whose pc-rel target equals the dummy's -126 jump-table target -> rewrite as `4eae ff82` (jsr a6@(-126)); miss -> CloseLibrary+bail. CacheClearU, Forbid, then 32x SetFunction(layers, -30..-216 step 6, d0=*(a5@(lvo+2)) = dummy slot target), Permit, CloseLibrary(layers). |
| h0+0x454 | _patchinstall | Walk _patchtab {lvo.w, func.l}: moveaw lvo->a0, a1=lib+42 (layers), gate on record version word func-14 (=39) <= exec ver, SetFunction, then func-8=libbase, func-4=oldvec (predecrementing a3). Terminates on lvo==0 or version gate. |
| h0+0x5b2 | _sbdead | Dead code (no incoming branches): earlier variant of the SwapBits fast path mixing eng.-918 alloc + eng.-30 convert + cgx.-84 + eng.-924. |
| h0+0x740 | _sb_alloc | Engine-buffer alloc for the cache path (described above); on failure unwinds through the caller's frame and tail-calls the original vector. |
| h0+0x7da | _sb_fill | eng.-30 conversion call filling the cached buffer / swapping regions (described above). |
| h1+0x26e | _roverlap | Rectangle-intersect test: returns 1 iff rect(a0) overlaps rect(a1); used by MoveSizeLayer against front-layer bounds. |

## Exec calls used

`-96 FindResident, -102 InitResident, -132 Forbid, -138 Permit,
-210 FreeMem, -252 Remove, -414 CloseLibrary, -420 SetFunction,
-552 OpenLibrary, -624 CopyMem, -636 CacheClearU, -684 AllocVec`
plus `moveal 4:w/l,a6` SysBase fetches.

## Layers calls used (on the a6=layers base)

`-48 UpfrontLayer, -120 LockLayerInfo, -138 UnlockLayerInfo,
-192 CreateBehindHookLayer, -216 DoHookClipRects` plus the saved
original vectors tail-called from each CYBL record (+0xe) and the
32-vector repoint `-30..-216`.

## Other calls

`graphics -528 ClearRegion`; `cybergraphics -84` (reserved slot in the
public FD — CGX-internal chunky/native swap entry); `*(layers+34)
engine -30/-918/-924`.
