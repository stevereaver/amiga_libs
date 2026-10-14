# fortunates.library 1.4 — vectors

Absolute-longword functab embedded in hunk0 at +0xea, 17 entries +
`0xffffffff` terminator. All offsets are hunk0-relative.

| LVO | h0 off | fn          | summary |
|-----|--------|-------------|---------|
| -6   | 0x21a | Open        | OpenCnt (lib+32)++ , returns lib base. |
| -12  | 0x228 | Close       | OpenCnt--; returns 0. |
| -18  | 0x23c | Expunge     | seglist = lib+44; Remove(lib); CloseLibrary ×9 (BSS +4..+36); FreeMem(lib-4 seg hdr + 184). |
| -24  | 0x2d2 | null stub   | `moveq #0,d0; rts`. |
| -30  | 0x2d6 | AvailMemCmp | AvailMem(0x20004=MEMF_LARGEST|chip-ish) + AvailMem(0x20002); d0 = sum, d1 = 0. |
| -36  | 0x308 | BssPtr      | returns lea(_bss+4) — pointer into the BSS hunk (dependency bases). |
| -42  | 0x310 | LoadFile    | **d1** = path (a0 unused — quirk). dos Open(d1,MODE_OLDFILE=1005); on fail returns 1. AllocVec(4096) scratch, Read header (12B), Read next (8B); parses FORM/RGB8/BMHD chunks; AllocVec(16) body hdr; FreeVec scratch; Close. Returns d0=status, d1=buffer ptr. |
| -48  | 0x452 | FindTag     | a0=list, d0=key. Stride-12 entries: each iter `addql #4,a0` then reads key@+4/val@+8; key==0 -> -1; hit -> returns val. (List layout: 4-B gap, key, val.) |
| -54  | 0x466 | ReqFortune  | a0=args. reqtools: AllocVec(64), rtAllocRequest(-30), build path via rtRequest(-48,-54), sprintf "drawer/file" into _bss+0x28 buffer, FreeVec. Returns pointer to path buffer. |
| -60  | 0x6d8 | ShiftBit    | a0=buf: `lsll #8` family byte-shift; returns 8. |
| -66  | 0x6ea | PenMetric   | d0=x,d1=y pen-metric compute (d4=0x333 residue); returns 0 on the tested args. |
| -72  | 0x718 | UnpackRow   | a0=src,a1=dst,d0=len — PackBits-style row decompress (literal/repeat opcodes). |
| -78  | 0x74e | UnpackCol   | a0=src,a1=dst,d0=len — column-variant decompressor (stride writes). |
| -84  | 0x784 | Interleave  | a0=planar src,a1=dptrs,d0=w,d1=h,d2=planes,d3=rowmod — interleave bitplanes row-wise. |
| -90  | 0x7ba | Interleave2 | a0=dptrs,a1=src — inverse order wrapper. |
| -96  | 0x7c4 | MakeBody    | a0=srcm,a1=out,a2=words,d0=w,d1=h,d2=planes,d3=rowmod — builds ILBM BODY. |
| -102 | 0x8bc | MakeImg     | a0=pixels,d0=w,d1=h,d2=path,d3=bmhd-size — writes FORM/ILBM file (dos Open MODE_NEWFILE=1006, Write BMHD+BODY, Close), returns bytes written. |

## Internal helpers (h0)

| off | fn | summary |
|-----|-----|---------|
| 0x152 | initfn   | stores lib (a5+36) and seglist (a5+44); OpenLibrary ×9 into BSS +4..+36 (dos/intuition/graphics/gadtools/icon/diskfont/asl/reqtools/workbench); on the last failing -> `Alert(0x38007)` via raw `moveal ($4).l,a6`. Also caches `*4` (SysBase) at _bss+0. Returns lib. |
| 0x5ba | _f5ba    | shared epilogue for the requester path: sprintf "drawer" prefix + rtFreeRequest. |
| 0x62e | _f62e    | path-append helper: strlen/copy loop, appends '/' + filename into the _bss+0x28 buffer. |

## Dependency bases (BSS hunk h2, 152 B)

| off | contents |
|-----|----------|
| +0  | SysBase copy (`movel 4:w`) |
| +4  | DOSBase          |
| +8  | IntuitionBase    |
| +12 | GfxBase          |
| +16 | GadToolsBase     |
| +20 | IconBase         |
| +24 | DiskfontBase     |
| +28 | AslBase          |
| +32 | ReqToolsBase     |
| +36 | WorkbenchBase    |
| +0x28.. | requester path buffer (sprintf target) |
| ..152 | misc library state |
