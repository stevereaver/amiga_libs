# cyberlayers_40.8.library -- vectors

## Own vectors (word-mode functab @h0+0xd2, base-relative offsets)

| LVO | fn (h0) | role |
|-----|---------|------|
| -6  | 0x4b2   | Open: `addqw #1,a6@(32)`, `bclr #3,a6@(14)`, d0=lib |
| -12 | 0x4c0   | Close: dec opencnt; if 0 and DELEXP bit3 -> Expunge |
| -18 | 0x4d4   | Expunge: deferred flag set if open; else `d2=a5@(38)` seglist, exec Remove + FreeMem, d0=seglist |
| -24 | 0x51a   | stub `moveq #0,d0; rts` (also stored at lib+50 by initfn) |

## initfn @h0+0xfe (d0=lib, a0=seglist, a6=exec)

lib fields written: +34 execbase, +38 seglist, +42 layersbase(v39),
+46 graphicsbase(v39), +50 &h0+0x51a, +54 cybergraphicsbase(v40;
required -- zero result aborts init).

Then calls `_clone` @0x152 and `_install` @0x454.

## _clone @0x152

Requires exec >= 39. FindResident("layers.library"); AllocVec
(EndSkip-base); CopyMem; rebase clone fields +2/+6/+0x12/+0x16, write
"layersdummy.library" into clone +0x0e (rt_Name); rebase the pointed
InitTable's +4/+8/+12/+0x28; InitResident(clone, 0) -> a5=clone lib.

Then OpenLibrary("layers.library") -> a3 (the live lib). Scan clone
bytes for `4eba` whose pc-rel target equals clone's -126 fn; patch to
`4eae ff82` (jsr a6@(-126)); CacheClearU; Forbid; 33x SetFunction:
`d0=clone@(-28-k*6)` (the clone jmp-slot targets) -> layers vectors
-30,-36,...,-216; Permit; CloseLibrary(a3).

## _install @0x454 (patch table @0x48c)

Entries {s16 LVO, relocated fn}:

| LVO  | fn        | target |
|------|-----------|--------|
| -36  | h1+0x12   | CreateUpfrontLayer -- blk0, bsr -> blk1 body |
| -186 | h1+0x2e   | CreateUpfrontHookLayer -- blk1 (SUPER: delegate via stored oldfn; else create SIMPLE + restore flags, hook@layer+118, ClearRegion, DoHookClipRects) |
| -60  | h1+0xe4   | MoveLayer -- blk2, bsr -> MoveSizeLayer(l,dx,dy,0,0) |
| -180 | h1+0x130  | MoveSizeLayer -- blk4: SMART layers w/o obscured cliprects or overlap relabel SIMPLE and delegate; else call orig |
| -66  | h1+0x108  | SizeLayer -- blk3, bsr -> MoveSizeLayer(l,0,0,dx,dy) |
| -126 | h0+0x530  | embedded CYBL blk (layer/cliprect management; in-clone self-calls converted to `jsr a6@(-126)`) |

Guard: `fn-14` = block+4 = CYBL version word (all 0x27 = 39); skipped
entirely if it exceeds `execbase+20`. On success the two zero longs at
fn-8/fn-4 (block +0xa/+0xe) are filled with {our lib base, old fn} so
the replacement code can tail-call or delegate to the original.

## CYBL block format

`43 59 42 4c` magic, u16 min-exec-version (+4), u16 flag (+6),
long (+8, stays 0), long +0xc <- installed ourlib, long +0xe <- old
fn... layout: 18-byte header, code at +0x12. The h0 copy of the -126
patch carries the same header @h0+0x51e.
