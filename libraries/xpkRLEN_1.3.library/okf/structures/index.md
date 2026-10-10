# Structures

## Hunk layout (two hunks)

- **hunk0** (CODE, 0x2a0 bytes): module entry, RomTag, InitTable,
  absolute functab, InitStruct stream, seglist code slot, all
  routines, string table (incl. the XpkInfo name strings).
- **hunk1** (DATA, 0x84 bytes): XpkMode at +0x00, XpkInfo at +0x2a.
  xi_Name/xi_LongName/xi_Description relocate **into hunk0**;
  xi_ModeDesc relocates into hunk1.  PackerInfo's
  `lea 0x2a,a0` is hunk0's single relocation into hunk1.

## XpkSubBase (dataSize = 0x22)

Bare `struct Library` — there is **no** seglist field.  LibInit
stores the InitFunc a0 argument in a code-space longword at
hunk+0x7a (`movel a0,0x7a`), which LibExpunge reads back
pc-relative.  Reconstruction: `_segslot` in `xpkRLEN_lib.s`.

## XpkInfo (hunk1+0x2a)

| field | value |
|-------|-------|
| xi_XpkInfoVersion | 1 |
| xi_LibVersion | 1 |
| xi_MasterVersion | 0 |
| xi_ModesVersion | 0 |
| xi_Name | "RLEN" (hunk0+0x13e) |
| xi_LongName | "Run Length" (hunk0+0x144) |
| xi_Description | "Fast and simple compression usable for simple data" (hunk0+0x150) |
| xi_ID | 'RLEN' |
| xi_Flags | 9 = XPKIF_PK_CHUNK\|XPKIF_UP_CHUNK |
| xi_MaxPkInChunk | 0x7fffffff |
| xi_MinPkInChunk | 0 |
| xi_DefPkInChunk | 0x4004 |
| xi_*Msg | all NULL |
| xi_DefMode | 50 |
| xi_ModeDesc | XpkMode (hunk1+0) |

## XpkMode (hunk1+0x00)

xm_Next=0, xm_Upto=100, xm_Flags=1 (XPKMF_A3000SPEED),
xm_PackMemory=0, xm_UnpackMemory=0, xm_PackSpeed=140,
xm_UnpackSpeed=1043, xm_Ratio=45, xm_ChunkSize=0,
xm_Description="normal".

## XpkSubParams (codec argument block)

xsp_InBuf +0x00, xsp_InLen +0x04, xsp_OutBuf +0x08,
xsp_OutBufLen +0x0c, xsp_OutLen +0x10 — only these fields are
touched.  OutBufLen is the packer's output bound (unlike v1.5,
which bounds by InLen).

## InitStruct stream

`INITBYTE ln_Type=9, INITLONG ln_Name, INITBYTE lib_Flags=6,
INITWORD ver=1, INITWORD rev=3, INITLONG lib_IdString, term` —
identical field order to the RLEN/CBR0 family.
