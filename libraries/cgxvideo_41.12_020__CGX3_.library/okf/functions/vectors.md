---
file: vectors
---
# Vectors (15 abs-longs @h0+0xd4)

Names per CGX3 SDK `cgxvideo_lib.fd` (bias 30):

| LVO | name | target | notes |
|-----|------|--------|-------|
| -6  | Open | h2+0x13c | lazy dep-init (see below) |
| -12 | Close | h2+0x2e2 | `subq.w #1,lib+32` only — never closes deps, never unpatches |
| -18 | Expunge | h2+0x2f4 | `moveq #0,d0` — always refuses |
| -24 | ExtFunc | h0+0x134 | stub `moveq #0,d0;rts` |
| -30 | CreateVLayerHandleTagList(Screen,Tags)(a0,a1) | h2+0x728 | utility GetTagData(VOA_Error=0x88000008) out-ptr cleared; returns 0 unless vlayer list (lib+174) is EMPTY (single-VLayer guard); gfx -792 probe (`&0xf00f0000==0x40020000` -> gfx -960 width>=32 gate) |
| -36 | DeleteVLayerHandle(VLayerHandle)(a0) | h2+0xace | driver method 0xB02 via obj+104/lib+50 dispatch a6@(-156); gfx -948 if flag@+97.0; exec FreeSignal(-252)+FreeVec(-690) |
| -42 | AttachVLayerTagList(VLayerHandle,Window,Tags)(a0,a1,a2) | h2+0xda4 | fills indents +58/+62/+66/+70 from window/tag fields; layers InstallLayerInfoHook(-198); sets w@98=1 |
| -48 | DetachVLayer(VLayerHandle)(a0) | h2+0xfa8 | driver method 0xB04; layers InstallLayerInfoHook(NULL); clears +14, w@98=0 |
| -54 | GetVLayerAttr(VLayerHandle,AttrNum)(a0,d0) | h2+0x1038 | switch: 0x88000030 VOA_BaseAddress (method 0xB03 -> +54), 0x88000031 VOA_ColorKeyPen (+86 or -1), 0x88000032 VOA_ColorKey (+90 or -1) |
| -60 | LockVLayer(VLayerHandle)(a0) | h2+0x1104 | driver method 0xB05; returns 1 |
| -66 | UnlockVLayer(VLayerHandle)(a0) | h2+0x10ca | driver method 0xB06; returns 0 |
| -72 | SetVLayerAttrTagList(VLayerHandle,Tags)(a0,a1) | h2+0x113e | utility FindTagItem/GetTagData over VOA_LeftIndent..BottomIndent 0x88000001-4; gfx -960 pairs; bails early when +14 (window) NULL |
| -78,-84,-90 | reserved | h0+0x134 | stubs -> 0 |

Driver-method packets: id 0xB02..0xB06 (2818-2822) with
0x8009xxxx tag-ish args, dispatched `jsr a6@(-156)` with
a6 = VLayerHandle+50 (driver lib) and a1 = VLayerHandle+104
(driver object).

## Open() dep-init (first open only, gated by w@42)

Order: expansion.library v39 (result checked but never
stored/closed), dos.library v39 ->+68, utility.library v39
->+44, intuition.library v39 ->+48, layers.library v39
->+52, graphics.library v39 ->+56, cgxsystem.library v41
->+64, FindResident("cybergraphics.library") ->+60.  On
cybergraphics present: run patcher (h2+0), set w@42=1.
Success tail: `addq.w #1,+32` + `bclr #3,+14` (DELEXP).

Patcher (h2+0) walks h1+18 `{w:lvo,l:newfunc}` entries —
{-180,h0+0x1e2},{-168,h0+0x208} — against layers.library
(lib+52): for each, record = newfunc-0x12, skip unless
layers lib_Version >= rec+4 (39); exec SetFunction(lvo,
newfunc, layers); rec+10=cgxvideo lib base, rec+14=oldvec.

## CYBI hook records (6 x 0x26 B, h0+0x138..+0x21b)

Layout: +0 'CYBI', +4 w min-lib-version (0x27=39),
+6..+0x11 zeros (+10 libbase, +14 oldvec filled by the
installer), +0x12 trampoline `movem.l a3,-(sp); lea
(rec,pc),a3; jsr impl; movem.l (sp)+,a3; rts`.

| rec | impl | args shape | installed by |
|-----|------|-----------|--------------|
| +0x138 | h2+0x304 | a0,d0,d1 | external (intuition MoveWindow-shape) |
| +0x15e | h2+0x39c | a0,d0,d1 | external (intuition SizeWindow-shape) |
| +0x184 | h2+0x688 | a0,d0-d3 | external (MoveSizeWindow-shape) |
| +0x1aa | h2+0x434 | a0 | external; KPrintF "ActivateWindow wnd %08lx" -> intuition ActivateWindow-shape |
| +0x1d0 | h2+0x51c | a0,d0-d3 | own patchtab: layers -180 MoveSizeLayer |
| +0x1f6 | h2+0x5d8 | a0,a1 | own patchtab: layers -168 MoveLayerInFrontOf |

Every impl: call oldvec (rec+14 via a6=rec+10 lib), then
ObtainSemaphore(lib+128 "OverlaySemaphore"), walk vlayer
list (lib+174 MinList), match node+14 (Window*) or
window->WLayer (+124) against the arg, call h2+0xb38
refresh ("VLayer window frame refresh !"), ReleaseSemaphore,
return old result. The four records not in the h1 patchtab
are discovered by 'CYBI' magic-scanning (cgxsystem/
cybergraphics side) — their patch targets never appear in
this binary.
