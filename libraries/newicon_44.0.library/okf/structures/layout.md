# newicon_44.0 data structures

## Library globals (BSS hunk, 8 bytes)

| off | contents                          |
|-----|-----------------------------------|
| +0  | `g_icon` — icon.library v44 base  |
| +4  | `g_sys`  — SysBase                |

The disassembly's `moveal 0x0,a6` / `moveal 0x4,a6` are
DREL16-relocated references to these two longs.

## Handle (`struct NI`, 12 bytes, AllocMem MEMF_PUBLIC)

| off | field                         |
|-----|-------------------------------|
| +0  | `ni_dob`  — DiskObject*       |
| +4  | `ni_i1`   — image-1 record*   |
| +8  | `ni_i2`   — image-2 record*   |

All blocks are attached to `dob->do_FreeList` (+78) via
`AddFreeList`, so `-42` only calls `FreeDiskObject`.

## Image record (`struct NI_Img`, 16 bytes inside a 22B alloc)

| off | type  | field                            |
|-----|-------|----------------------------------|
| +0  | UWORD | `im_w`      (ICONA +39)          |
| +2  | UWORD | `im_h`      (+41)                |
| +4  | UWORD | `im_psz`    (+25/+27 palsize)    |
| +6  | UWORD | `im_flag`   — bit0: has-transp,
        |               bit1: skip upload (native img)  |
| +8  | APTR  | `im_pal`    (+21/+23 palette)    |
| +12 | APTR  | `im_data`   (+29/+31 imagedata)  |

`im_flag = (transp != -1) ? 1 : (mode != 0)`.

## Fake DiskObject fields used (offsets into do)

| off | use                                   |
|-----|----------------------------------------|
| +12 | old-style gadget width (w copied)      |
| +14 | old-style gadget height                |
| +16 | old-style gadget flags (`&= ~3`)       |
| +22 | `ga_GadgetRender` — NULL → 1×1 Image   |
| +54 | `do_ToolTypes`                         |
| +78 | `do_FreeList` (v44)                    |

## mkdef result block (24 bytes)

| off  | field                                   |
|------|------------------------------------------|
| +0   | 20-byte Image copy (from LayoutIconA'd   |
|      | `ga_GadgetRender`)                       |
| +20  | DiskObject*                              |

## icon.library tag IDs (0x80009000 + n) used

get query (-30): 39,41,17,21,25,29 (img1), 19,23,27,31
(img2), 1 (ErrorCode), plus 42 IsPaletteMapped, 50
RemapIcon, 45 GetDefaultType, 80 IsNativeIcon.

set uploads (-36): 38 SetWidth, 40 SetHeight, 36
SetAspectRatio(0x11), 28 SetImageData1, 20 SetPalette1, 24
SetPaletteSize1, 16 SetTranspColor1; img2: 30,22,26,18.
mkdef: same as img1-set + 1 ErrorCode-out.
put final: 57 DropChunkyIconImage, 58 DropNewIconToolTypes,
53 NotifyWorkbench.
