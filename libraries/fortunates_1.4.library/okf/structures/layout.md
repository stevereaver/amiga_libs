# fortunates.library 1.4 — layout

## Hunks

| # | type | body | contents |
|---|------|------|----------|
| 0 | CODE | 0x9d4 B (0x275 L) | RomTag + stub + name/idstr/dep-name strings, InitTable, 17-long functab, InitStruct datatab, all code; EndSkip -> h0+0x9d2, trailing `0000` pad. |
| 1 | DATA | 0x10 B (4 L) | three data longs + `0000` pad. |
| 2 | BSS  | 0x98 B (0x26 L) | dependency bases + requester path buffer + library state (see vectors.md). |

RELOC32 groups (original order, restored by `fixup.py`):
- h0 -> h0: self-references (matchtag/endskip + intra-code).
- h0 -> h2: BSS references (`_bss+N` operands scattered through initfn,
  Expunge, LoadFile, ReqFortune).
- h1 -> h0: none beyond its own trailer.

## RomTag (h0+4)

`rt_MatchTag -> h0+4`, `rt_EndSkip -> h0+0x9d2`, `rt_Flags = 0x80`
(AUTOINIT), `rt_Version = 1`, `rt_Type = NT_LIBRARY`, name ->
`"fortunates.library"`, idstr -> `"fortunates 1.4 (08.06.97)\r\n"`,
`rt_Init -> h0+0xda` InitTable.

## InitTable (h0+0xda)

| field | value |
|-------|-------|
| dsize | 0x30 (48-byte lib struct) |
| functab | -> h0+0xea (17 absolute longs + `ffffffff` term) |
| datatab | -> h0+0x132 InitStruct |
| initfn  | -> h0+0x152 |

## InitStruct datatab (h0+0x132)

`a008/0900` initbyte +8 type=9 (NT_LIBRARY), `800a` initlong +10
ln_Name -> _name, `a00e/0600` initbyte +14 flags=6, `9014/0001`
initword +20 ver=1, `9016/0004` initword +22 rev=4, `8018` initlong +24
ln_IdString -> _idstr, `0000 0000` term.

## Library struct (dsize 0x30)

| off | field |
|-----|-------|
| +32 | OpenCnt |
| +36 | lib self-ptr (initfn stash) |
| +44 | seglist (Expunge frees it) |

## Strings (h0)

`fortunates.library`, `fortunates 1.4 (08.06.97)\r\n`, then dependency
names: `dos.library`, `intuition.library`, `graphics.library`,
`gadtools.library`, `icon.library`, `diskfont.library`, `asl.library`,
`reqtools.library`, `workbench.library`.
