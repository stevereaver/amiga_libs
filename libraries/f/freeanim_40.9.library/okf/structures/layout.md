# freeanim.library 40.9 — layout

## File / hunk map

- HUNK_HEADER: names=0, 1 hunk, size 0x4c longs (304 B).
- hunk0 CODE @ file 0x20; body 0x130 B.
- RELOC32 @ file 0x150: one group, count=10, hunk 0,
  offsets (original order): `60 0a 88 76 5c 58 1a 16 12 06`
  — scrambled vs canonical ascending; `fixup.py` reorders.
- HUNK_END.

## h0 map

| off | contents |
|-----|----------|
| 0x00 | `70ff 4e75` — dead stub (moveq #-1; rts) |
| 0x04 | RomTag (packed, 0x1a B): matchtag->4, endskip->0x130, flags 0x81, v40 |
| 0x1e | `"freeanim.library\0"` |
| 0x2f | `"freeanim.library 40.9 (11.8.95)\r\n"` + NUL@0x50 + `4e71` nop @0x51 + pad@0x53 |
| 0x54 | InitTable: dsize 0x26, ftab 0x64, dtab 0x70, initfn 0x120 |
| 0x64 | functab (word-offset): `ffff 008c 0094 0030 002c ffff` |
| 0x70 | datatab InitStruct: type=9, name, flags=6, ver=40, rev=9, idstr |
| 0x8c | `4e71` nop pad |
| 0x90 | reserved stub |
| 0x94 | _expunge |
| 0xf0 | _open |
| 0xf8 | _close |
| 0x120 | _initfn |
| 0x130 | EndSkip |

## Library structure (dsize 0x26)

- +0x10/+0x12: neg/pos size words (used by expunge for FreeMem)
- +0x14: flags byte (bit3 = LIBF_DELEXP at byte +0xe — see note)
- +0x20: opencnt (word)
- +0x22: seglist (stored by initfn; expunge returns it)

InitStruct datatab sets ln_Type=9, ln_Name, lib_Flags=6
(SUMUSED|CHANGED), Version=40, Revision=9, IdString.

Flag bit tested via `btst.b #3, 0xe(a6)` — offset 0xe = ln_Flags
byte, not lib_Flags (0x14). LIBF_DELEXP lives at lib+0xe bit 3
per exec convention.
