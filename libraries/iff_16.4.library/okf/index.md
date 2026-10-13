# iff.library 16.4 — OKF index

Classic **IFF ILBM file toolkit** by Christian A. Weber
("IFF 16.4 (16-May-1989) by Christian A. Weber") — the
precursor of his later `iff.library`/IFFL releases.  Loads
whole FORM files into memory, walks chunks, converts CMAP
palettes, decodes ByteRun1/raw ILBM bodies into a `BitMap`,
and streams ILBM files back out (raw or ByteRun1-compressed).

The image doubles as a CLI command: running the file prints
its ID string via `dos.library` `Output()`/`Write()` and
returns `RETURN_WARN` (5) — the `'CHW!'` signature at hunk+0
keeps the resident scanner from tripping over the bootstrap.

- Binary: `binary/iff_16.4.library` — 2340 bytes, m68000.
- Reconstruction: `source/` — C API (`iff.c`) + AutoInit
  glue/lifecycle (`iff_lib.s`).

## Hunk layout (original)

Single `CODE` hunk (~2216B body): bootstrap/CLI entry at +0x00,
`'CHW!'` + `bra` at +0x08, RomTag at +0x0c (AUTOINIT, v16,
NT_LIBRARY, pri 1), name/id/"dos.library" strings, InitTable
at +0x94 (dataSize=58, functab@+0xa4 — 15 vectors, datatab
@+0xe4, initfn@+0x110), then library code.  25 self-relocations.

datatab uses the 24-bit-offset extended InitStruct opcodes
(`$e0` byte / `$d0` word / `$c0` long): type=NT_LIBRARY(9)
@8, name ptr @10, flags=6 @14, version=16 @20, revision=4 @22,
idstring ptr @24.

## Vectors (15, offsets-into-hunk functab)

| LVO | Target  | Function                                |
|-----|---------|-----------------------------------------|
| -6  | +0x13e  | LibOpen — per-task node, rejects dupes  |
| -12 | +0x15c  | LibClose — removes node, deferred expunge|
| -18 | +0x17a  | LibExpunge — correct impl               |
| -24 | +0x1b8  | null stub (`moveq #0,d0; rts`)          |
| -30 | +0x206  | OpenIFF (autodetect memattr)            |
| -36 | +0x20e  | CloseIFF (`FreeMem(h-4, *(h-4))`)       |
| -42 | +0x21e  | FindChunk                               |
| -48 | +0x246  | GetBMHD (FindChunk+8)                   |
| -54 | +0x250  | GetColorTab (CMAP → 0x0RGB words)       |
| -60 | +0x2a4  | DecodePic (ILBM raw/ByteRun1 + mask)    |
| -66 | +0x592  | SaveBitMap                              |
| -72 | +0x596  | SaveClip (byte-window variant)          |
| -78 | +0x822  | IFFError (per-task error, read+clear)   |
| -84 | +0x830  | GetViewModes (CAMG or derived)          |
| -90 | +0x200  | NewOpenIFF (explicit memattr in d0)     |

## Verification status

machine68k oracle (`work/oracle.py` main battery +
`work/edge.py`): **byte-identical** output against the
original across the full API — lifecycle incl. per-task
duplicate-open rejection and deferred expunge, OpenIFF/
NewOpenIFF allocation attributes (8SVX→CHIP), FindChunk
boundary scan, GetBMHD/GetColorTab, raw + ByteRun1 DecodePic
with mask rows and overrun semantics, ByteRun1 encode limits,
SaveBitMap/SaveClip streaming output incl. FORM-size seek-back
patching, per-task IFFError codes 16/19/24/25/26/27/28,
GetViewModes derivation (HIRES/LACE/HAM), flag-bit7→CAMG-HAM.

## Files

- `functions/vectors.md` — vector/LVO details + ABI
- `functions/codec.md` — ByteRun1 decode/encode, raw path,
  save-worker streaming strategy, internal helpers
- `structures/layout.md` — hunk map, private lib data,
  per-task open node, BMHD record
- `findings/defects.md` — shipped quirks and bugs reproduced
- `log.md` — work log
