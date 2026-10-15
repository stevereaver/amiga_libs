# structures touched by fastlayers.library

## Layer fields used (matches <graphics/clip.h>)

| off  | field        | use |
|------|--------------|-----|
| +0   | front        | front-chain walk in MoveSizeLayer |
| +8   | ClipRect     | cliprect lobs scan |
| +12  | rp           | (dead DoHookClipRects arg) |
| +16  | bounds       | new-bounds computation, front-layer overlap test |
| +30  | Flags        | SIMPLE/SMART manipulation + refresh-flag clearing |
| +68  | LayerInfo    | LockLayerInfo/UnlockLayerInfo, top_layer test |
| +118 | BackFill     | set to (Hook*)1 sentinel on create |
| +156 | DamageList   | ClearRegion on create |

## ClipRect fields used

| off | field | use |
|-----|-------|-----|
| +0  | next  | list walk |
| +8  | lobs  | non-NULL -> layer is occluded -> no fast path |

## Layer_Info fields used

| off | field      | use |
|-----|------------|-----|
| +0  | top_layer  | topmost test -> skip scans |

## Flag bits (layer->Flags)

- 0x01 LAYERSIMPLE, 0x02 LAYERSMART, 0x04 LAYERSUPER
- 0x40 LAYERBACKDROP — create dispatch mask is `& 0x44`
- 0x80 LAYERREFRESH, 0x200 LAYERIREFRESH, 0x400 LAYERIREFRESH2 —
  cleared by `& ~0x680` after the cheap create

## Packed Resident (as used by the scan)

| off | field |
|-----|-------|
| +2  | rt_MatchTag |
| +6  | rt_EndSkip (module end -> size) |
| +14 | rt_Name |
| +22 | rt_Init -> InitTable; +4 = functab ptr |

Module code assumed to start at +26.
