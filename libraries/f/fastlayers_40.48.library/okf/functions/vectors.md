# fastlayers.library — vectors and LVOs

## Own functable (LONG entries)

| LVO | target | notes |
|-----|--------|-------|
| -6  | LibOpen    | `opencnt++`, clears private flag bit3 @base+34, returns a6 |
| -12 | LibClose   | `opencnt--`; if 0 && flag34.3 `bsr` Expunge (dead: flag never set) |
| -18 | LibExpunge | `return 0` — never expunges |
| -24 | LibExpunge | same stub |

## Patched layers.library vectors (patchtab)

| LVO  | layers function          | new target |
|------|--------------------------|------------|
| -186 | CreateUpfrontHookLayer   | new: flags&0x44 -> original; else cheap create |
| -36  | CreateUpfrontLayer       | wrapper -> new -186 with hook=(Hook*)0 |
| -60  | MoveLayer                | wrapper -> new -180 (dw=dh=0) |
| -180 | MoveSizeLayer            | new: SMART-only fast path (see below) |
| -66  | SizeLayer                | wrapper -> new -180 (dx=dy=0) |

## exec calls

-96 FindResident, -132 Forbid, -138 Permit, -420 SetFunction,
-552 OpenLibrary (x3), -624 CopyMem, -636 CacheClearU,
-684 AllocVec

## layers calls (a6 = layers base, from patched routines)

-48 UpfrontLayer, -120 LockLayerInfo, -138 UnlockLayerInfo,
-192 CreateBehindHookLayer, -216 DoHookClipRects (unreachable —
see findings)

## graphics calls

-528 ClearRegion (via `flbase->fl_Gfx`)

## LibInit flow

```
base+36 = a6 (exec), base+52 = a0 (seglist), flbase = base
OpenLibrary(layers,39) -> +48   fail -> return 0
OpenLibrary(graphics,39) -> +40 fail -> return 0
OpenLibrary(utility,39) -> +44  fail -> return 0
orig126 = *(layers - 124)          ; vector -126 jmp target
res = FindResident(layers->ln_Name)
size = res->EndSkip - res          ; packed Resident @6
copy = AllocVec(size, 0) -> +56
CopyMem(res, copy, size);  delta = copy - res
Forbid()
scan res+26 .. res+size for word 0x4eba (jmp pc@(d16)):
    if pos+2+disp == orig126:  copy@pos+delta <- {4eae, ff82}
walk layers' InitTable->functab words, from index 1,
  vectors -6, -12, ... : if vector target == ftab+w
    SetFunction(layers, lvo, (ftab+w)+delta)
for each patchtab {lvo,new,saved}:
    saved = SetFunction(layers, lvo, new)
CacheClearU(); Permit(); return base
```

## NewCreateUpfrontHookLayer (-186)

```
if flags & (LAYERBACKDROP|LAYERSUPER) = 0x44:
    return saved_orig(all args forwarded, tail call)
LockLayerInfo(li)
l = CreateBehindHookLayer(li, bm, x0,y0,x1,y1,
                          (flags&~3)|1 /* force SIMPLE */,
                          hook=(Hook*)1, bm2)
if !l: UnlockLayerInfo; return 0
UpfrontLayer(0, l)
l->Flags = (l->Flags & ~3) | (flags & 3)   ; caller bits back
l->BackFill = (Hook*)1                      ; no-backfill sentinel
ClearRegion(l->DamageList)                  ; via flbase->gfx
l->Flags &= ~0x680                          ; REFRESH|IREFRESH|IREFRESH2
if (a3 != 1) DoHookClipRects(a3, l->rp, a2) ; dead: a3 always 1
UnlockLayerInfo(li); return l
```

## NewMoveSizeLayer (-180)

```
if (l->Flags & 7) != LAYERSMART: return saved_orig(...)
if dx==dy==dw==dh==0: return 1        ; `moveq #1,d4` mid-insn
nb = { bx0+dx, by0+dy, bx1+dx+dw, by1+dy+dh }
if nb.x1 < nb.x0 || nb.y1 < nb.y0: return 0
flag = 1
LockLayerInfo(li = l->LayerInfo)
if l != li->top_layer:
    for cr in l->ClipRect: if cr->lobs -> flag = 0, break
    if flag:
        for f in l->front..: if overlap(nb, f->bounds)
            -> flag = 0, break
if flag: l->Flags = (Flags & ~2) | 1     ; LAYERSIMPLE
ret = saved_orig(l, dx, dy, dw, dh)
if flag: l->Flags = (Flags & ~1) | 2     ; LAYERSMART back
UnlockLayerInfo(l->LayerInfo)
return ret
```
