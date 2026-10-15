---
file: vectors
---
# Vectors (abs-long functab @h0+0xb14, 6 entries, -1 term @0xb2c)

Built by exec MakeLibrary from the init routine. Jump table at
lib-6..lib-36 (NegSize 36, PosSize 0x54).

-6  Open    ->h0+0x1dc  opencnt++, clear lib_Flags bit3
                        (DELEXP), ObtainSemaphore(lib+0x26);
                        if opencnt==1 call openlibs@h0+0x298
                        (opens dos/gfx/intuition/utility v36,
                        muigfx v19, layers v36 -> a4+0x76c/768/
                        764/770/774/778; on failure CloseLibrary
                        unwinds); ReleaseSemaphore; ret lib|0.
-12 Close   ->h0+0x220  ObtainSemaphore; call closelibs@h0+0x34a
                        (closes all six if opencnt==1);
                        ReleaseSemaphore; opencnt--; if cnt==0
                        && DELEXP -> tail expunge@h0+0x17e,
                        ret its d0 (seglist).
-18 Expunge ->h0+0x17e  if opencnt>0 -> set DELEXP, ret 0;
                        else closelibs (h0+0x282 variant), exec
                        Remove(lib), FreeMem(lib-negsz,
                        neg+pos), ret seglist (lib+0x22).
-24 Reserved->h0+0x0    relocated-ZERO slot -> the reserved
                        `moveq #0,d0; rts` at CODE+0.
-30         ->h0+0x768  CREATE help object. (d0=x,d1=y,
                        a0=host obj, a1=helptext or 0->GetAttr
                        0x80428e93 via dispatcher stub h0+0xb30)
                        exec AllocVec(188,MEMF_CLEAR) -> a3;
                        a3+4=obj, a3+164=obj+28->+4 (screen),
                        a3+176=text, MUIGfx -168 alloc bitmap ->
                        a3+8, MUIGfx -66 decode packed image
                        (a4+0 & a4+0x14) -> a3+168, gfx
                        InitRastPort/SetFont/SetDrMd, MUIGfx -204
                        text extent -> a3+12..20, MUIGfx -42 ->
                        a3+56, clamp vs screen w/h -> a3+32/36,
                        MUIGfx -30 -> a3+60 (layer/bitmap),
                        draw loop bsr h0+0x45c (SetAPen/RectFill/
                        gfx -606/-636 tiling border+fill),
                        intuition -606 opens window -> a3+180,
                        gfx -606 blit. Ret a3 (0 on any fail ->
                        bsr h0+0x6be dispose then ret 0).
-36         ->h0+0x6be  DISPOSE. (a0=obj from -30, NULL ok)
                        intuition -72 CloseWindow(a5+180);
                        if a5+60: ClearPointer(-60) on win+16
                        when a5+28==0, then MUIGfx -36 x3 for
                        a5+60/a5+172/a5+168; MUIGfx -174 on
                        a5+8; if a5+176 && a5+184: dispatcher
                        call (tag 0x8042d35a); exec FreeVec(a5).

Internal helpers: h0+0x264 set-a4 stub (stores exec ->a4+0x760),
h0+0x298 openlibs, h0+0x34a closelibs, h0+0x3dc text/line blit
helper (gfx -636/-606 + TextLength), h0+0x45c render loop,
h0+0x6a2 a4 thunk, h0+0xb30..0xc10 SAS/C DoMethod-style
dispatch stubs (pea h0+0xb9e = shared a2-restore return).
