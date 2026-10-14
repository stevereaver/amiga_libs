# newicon.library 44.0 — OKF index

Stephan Rupprecht's **NewIcons emulation library**
("newicon.library 44.0 (30.12.99) emulation (C) 2000 by Stephan
Rupprecht").  Not the real NewIcons commodity — a thin
compatibility wrapper that maps the newicon.library API onto
`icon.library` v44 (`IconControlA`/`GetIconTagList`/
`PutIconTagList`/...).  Intended to be opened only by the
`newicons` commodity: `Open()` refuses any caller whose
program-name FilePart is a case-insensitive prefix of
`"newicons"` (i.e. it *rejects* the real commodity — the
emulation exists to serve the commodity's clients).

- Binary: `binary/newicon_44.0.library` — 2468 bytes, m68020+
  (Init requires `AttnFlags & AFF_68020`; uses `bfexts`).
- Reconstruction: `source/` — register-argument C
  (`newicon.c`) + AutoInit skeleton/lifecycle stubs
  (`newicon_lib.s`).  `work/oracle.py` verifies original vs
  rebuild on machine68k: 23 scenarios, all event-identical.

## Hunk layout (original)

3 hunks: CODE (0x828 B body), DATA (0xbc B), BSS (8 B).
Relocations are `DREL16` (word offsets, target-hunk
numbered).

- CODE +0x00: `moveq #-1`/`rts` stub (null vector target A)
- CODE +0x06: `clrl`/`rts` (null vector target B)
- CODE +0x0c: Init — needs AFF_68020, opens icon.library v44
  into BSS+0, SysBase into BSS+4; on failure frees the
  library allocation itself and returns 0.
- DATA +0x00: absolute functab — 13 `.long` entries
  (DREL16'd against CODE).  +0x34: InitTable
  (dataSize=0x7a, functab@data+0, datatab@data+0x44,
  initfn@CODE+0x0c).  +0x40: RomTag (AUTOINIT, v44, pri 0,
  `rt_EndSkip` = CODE hunk end).

## Vectors (13)

| LVO | Target    | Function                                   |
|-----|-----------|--------------------------------------------|
| -6  | C+0x88    | Open — dos.library 40, GetProgramName +
        |           FilePart; refuses `stri(name)=="newicons"`;
        |           clears LIBF_DELEXP, bumps OpenCnt      |
| -12 | C+0x164   | Close — dec OpenCnt, deferred expunge at 0 |
| -18 | C+0x114   | Expunge — CloseLibrary(iconbase), Remove,
        |           FreeMem(base-negsize, negsize+possize)   |
| -24 | C+0x6     | null (`clrl`)                              |
| -30 | C+0x2c8   | xget core — GetIconTagList + handle build  |
| -36 | C+0x5ae   | put — IsNativeIcon/DupDiskObjectA/ictrl
        |           uploads + PutIconTagList             |
| -42 | C+0x6f2   | free handle → FreeDiskObject               |
| -48 | C+0x6fc   | get-default helper (xget mode)             |
| -54 | C+0x702   | dupimg — CopyMem 20B image record          |
| -60 | C+0x70e   | forward → icon -156 (IconControlA)         |
| -66 | C+0x714   | mkdef — NewDiskObject(3) + default image   |
| -72 | C+0x6     | null                                       |
| -78 | C+0x6     | null                                       |

## Helpers inside xget/put

- `xget` (0x2c8): tag-queries the DiskObject for size, both
  image-1/image-2 records (w/h/palette/palsize/imgdata/
  transparent pens), ErrorCode; on error returns a partial
  handle.  Non-palette-mapped icons recurse through the
  `DEFAULTIMAGE` tooltype (mode=2).
- `remap` (0x262): swaps palette entry 0 ↔ transparent pen,
  rewrites pen-0 pixels.
- `mkdef` (0x714): NewDiskObject(3) + IconControlA uploads +
  LayoutIconA + CopyMem of the 20-byte Image record.
