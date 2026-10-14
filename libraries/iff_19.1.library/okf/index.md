# iff.library 19.1 — OKF index

**IFF ILBM/ANIM file toolkit** by Christian A. Weber
("IFF 19.1 (09-Oct-1990) by Christian A. Weber") — the
direct successor of iff.library 16.4.  Loads whole FORM
files into memory, walks chunks, converts CMAP palettes,
decodes ByteRun1/raw ILBM bodies into a `BitMap`, streams
ILBM files back out, and — **new in 19.1** — plays ANIM
operation-5 DLTA frames straight into a `BitMap`.

The image doubles as a CLI command: running the file prints
its ID string via `dos.library` `Output()`/`Write()` and
returns `RETURN_WARN` (5) — the `'CHW!'` signature at hunk+0
keeps the resident scanner from tripping over the bootstrap.

- Binary: `binary/iff_19.1.library` — 2716 bytes, m68000.
- Reconstruction: `source/` — C API (`iff.c`) + AutoInit
  glue/lifecycle (`iff_lib.s`), built with
  `m68k-amigaos-gcc -O2 -m68000 -nostdlib`.

## Hunk layout (original)

Single `CODE` hunk (`0x280` longs = 0xa00 bytes) + `HUNK_END`.

| Code off | Content |
|----------|---------|
| +0x00 | CLI bootstrap: `bra` over `'CHW!'`, OldOpenLibrary(dos), Output, Write(idstr,45), CloseLibrary, d0=5, rts |
| +0x34 | RomTag `4afc`: matchtag=0x34, endskip=0x1fe, RTF_AUTOINIT, ver 19, NT_LIBRARY, pri 0 |
| +0x4e | `"iff.library"` / `"IFF 19.1 (09-Oct-1990) by Christian A. Weber\n"` / `"dos.library"` |
| +0x94 | InitTable: dataSize=0x3c (60), functab@0xa4, datatab@0xe8, initfn@0x108 |
| +0xa4 | functab — 16 absolute longs + `-1` |
| +0xe8 | datatab — **8-bit-offset** InitStruct ops (`$a0` byte / `$90` word / `$80` long), byte entries padded to even |
| +0x108 | LibInit: caches ExecBase@34, seglist@42, OldOpenLibrary→DOSBase@38, NEWLIST@46 |
| +0x138 | LibOpen / +0x180 LibClose / +0x1b8 LibExpunge |
| +0x1fc | reserved `rts` stub (returns nothing) |
| +0x200 | OpenIFF (memattr=-1) → falls into NewOpenIFF worker |
| +0x208 | NewOpenIFF + open worker |
| +0x2bc | CloseIFF / +0x2dc FindChunk |
| +0x30c | GetBMHD / +0x338 GetColorTab |
| +0x380 | DecodePic (raw + CmpByteRun1 + mask + 24-plane scratch) |
| +0x49c | SaveBitMap / +0x4b4 SaveClip (+ helpers to ~0x7eb) |
| +0x7ec | findnode (SysBase+276 ThisTask; no FindTask call) |
| +0x808 | clrerr helper / +0x814 seterr helper |
| +0x824 | IFFError / +0x840 GetViewModes (+0x85a calcmodes) |
| +0x89c | DecodeAnim + op-5 column decoder (Duff unrolled ×8) |

datatab initialises: ln_Type=9 @8, ln_Name @10, lib_Flags=6
@14, lib_Version=19 @20, lib_Revision=1 @22, lib_IdString @24.

## Vectors (16 — one more than 16.4)

| LVO  | Target  | Function |
|------|---------|----------|
| -6   | +0x138  | LibOpen — per-task node, rejects dupes |
| -12  | +0x180  | LibClose — removes node, deferred expunge |
| -18  | +0x1b8  | LibExpunge — deferred via lib_Flags bit3 |
| -24  | +0x1fc  | reserved `rts` (returns garbage in d0) |
| -30  | +0x200  | OpenIFF (autodetect memattr) |
| -36  | +0x2bc  | CloseIFF |
| -42  | +0x2dc  | FindChunk |
| -48  | +0x30c  | GetBMHD |
| -54  | +0x338  | GetColorTab (masked 0x0RGB) |
| -60  | +0x380  | DecodePic |
| -66  | +0x49c  | SaveBitMap |
| -72  | +0x4b4  | SaveClip (byte-window) |
| -78  | +0x824  | IFFError (per-task, read+clear, **-1 if no node**) |
| -84  | +0x840  | GetViewModes (CAMG & 0xffff9efd or derived) |
| -90  | +0x208  | NewOpenIFF (explicit memattr) |
| -96  | +0x89c  | **DecodeAnim (new)** — ANHD op5 + DLTA → BitMap |

## Verification

`work/oracle.py` (machine68k, M68020) emulates exec/dos and
drives all 16 vectors through real in-memory structures;
`work/build_iff.py` generates the fixtures (raw ILBM, RLE
with a 0x80-NOP, 3-plane→shallow-bitmap, 8SVX, op-5 ANIM +
three ANIM error fixtures, bad/short forms, missing
BMHD/BODY/CMAP, bad compression, PBM).

Result: **`diff orig.log rebuild.log` is empty** — every
return value, error code, plane byte, saved file byte,
alloc/free/remove/close call and deferred-expunge flag is
identical between the original 2716-byte binary and the
rebuilt library.  See `okf/log.md`.
