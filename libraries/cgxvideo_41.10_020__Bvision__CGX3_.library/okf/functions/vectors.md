---
file: vectors
---
# Vectors (15 abs-longs @h0+0xd8)

Names per CGX3 SDK `cgxvideo_lib.fd` (bias 30) — same VLayer
API as the 41.12 siblings.

| LVO | name | target | notes |
|-----|------|--------|-------|
| -6  | Open | h2+0x13c | lazy dep-init on first open (w@42 gate) |
| -12 | Close | h2+0x2e2 | `subq.w #1,lib+32` only — never closes deps, never unpatches |
| -18 | Expunge | h2+0x2f4 | `moveq #0,d0` — always refuses |
| -24 | ExtFunc | h0+0x138 | stub `moveq #0,d0;rts` (shared w/ -78/-84/-90) |
| -30 | CreateVLayerHandleTagList(Screen,Tags)(a0,a1) | h2+0x728 | utility GetTagData(VOA_Error=0x88000008) out-ptr cleared; returns 0 unless vlayer list (lib+174) is EMPTY (single-VLayer guard); gfx GetVPModeID(-792) probe (`&0xf00f0000==0x40020000` -> gfx GetBitMapAttr(-960) width<=32 gate); cgxsystem method (-60 via lib+64) |
| -36 | DeleteVLayerHandle(VLayerHandle)(a0) | h2+0xace | driver method 0xB02 via obj+50/lib dispatch a6@(-156); gfx ReleasePen(-948) if flag@97.0; exec Remove(-252)+FreeVec(-690) |
| -42 | AttachVLayerTagList(VLayerHandle,Window,Tags)(a0,a1,a2) | h2+0xda4 | fills indent longs +58/+62/+66/+70 from window bytes +54/55/56 (zeroed when flag bit2 of wnd+26); sets w@98 |
| -48 | DetachVLayer(VLayerHandle)(a0) | h2+0xfb2 | driver method 0xB04; layers InstallLayerHook(-198) on wlayer (obj+14)+0x7c with hook obj+42; clears +14, w@98=0 |
| -54 | GetVLayerAttr(VLayerHandle,AttrNum)(a0,d0) | h2+0x1042 | switch: 0x88000030 VOA_BaseAddress (method 0xB03 -> +54), 0x88000031 VOA_ColorKeyPen (+86 or -1), 0x88000032 VOA_ColorKey (+90 or -1) |
| -60 | LockVLayer(VLayerHandle)(a0) | h2+0x110e | driver method 0xB05; returns 1 |
| -66 | UnlockVLayer(VLayerHandle)(a0) | h2+0x10d4 | driver method 0xB06; returns 0 |
| -72 | SetVLayerAttrTagList(VLayerHandle,Tags)(a0,a1) | h2+0x1148 | utility FindTagItem(-30)/GetTagData(-36) over VOA_LeftIndent..BottomIndent 0x88000001-4; folds results into +58 etc; bails when obj+14 (window) NULL |
| -78,-84,-90 | reserved | h0+0x138 | stubs -> 0 |

Driver-method packets: ids 0xB02..0xB06 (2818-2822) with
0x8009xxxx tag-ish args, dispatched `jsr a6@(-156)` with
a6 = VLayerHandle+50 (driver lib), a1 = VLayerHandle+104
(driver object), a2 = &packet.

## Open() dep-init (first open only, gated by w@42)

Order: expansion.library v39 (result checked, never stored/
closed — anchor quirk), dos.library v39 ->+68, utility.library
v39 ->+44, intuition.library v39 ->+48, layers.library v39
->+52, graphics.library v39 ->+56, cgxsystem.library v41
->+64, exec FindName(-276)(&SysBase->LibList @+0x17a,
"cybergraphics.library") ->+60. On success: run patcher
(h2+0), set w@42=1. Success tail: `addq.w #1,+32` +
`bclr #3,+14` (LIBF_DELEXP clear).

## Patcher (h2+0)

Walks h1+18 `{w:lvo,l:newfunc}` entries — {-180,h0+0x1e6},
{-168,h0+0x20c} — against layers.library (lib+52): for each,
record = newfunc-0x12, skip unless layers lib_Version >=
rec+4 (0x27=39); exec SetFunction(-420)(lvo,newfunc,layers);
rec+10=cgxvideo libbase, rec+14=oldvec.

## CYBI hook records (6 x 0x26 B, h0+0x13c..+0x1fa)

Layout: +0 'CYBI', +4 w min-lib-version (0x0027=39), +6..+0x11
zeros (+10 libbase / +14 oldvec filled by the installer),
+0x12 trampoline `movem.l a3,-(sp); lea (rec,pc),a3; jsr
impl; movem.l (sp)+,a3; rts` (impl reloc = the only h0->h2
code relocs @h0+0x158,+0x17e,+0x1a4,+0x1ca,+0x1f0,+0x216).

| rec | impl | installed by |
|-----|------|--------------|
| +0x13c | h2+0x304 | external (intuition MoveWindow-shape hook) |
| +0x162 | h2+0x39c | external (SizeWindow-shape) |
| +0x188 | h2+0x688 | external (MoveSizeWindow-shape) |
| +0x1ae | h2+0x434 | external (ActivateWindow-shape; contains the
  h2+0x516 KPrintF debug call site) |
| +0x1d4 | h2+0x51c | own patchtab: layers -180 MoveSizeLayer |
| +0x1fa | h2+0x5d8 | own patchtab: layers -168 MoveLayerInFrontOf |

The four "external" records carry no in-file references —
'CYBI' is self-describing; cgxsystem.library is presumed to
scan the hunks and install them as intuition window hooks
(same mechanism documented for the 41.12 siblings).
