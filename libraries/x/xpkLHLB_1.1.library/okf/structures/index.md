# Structures

## XpkSubBase (dataSize = 0x30)

| off | field |
|-----|-------|
| 0x00 | struct Library (34 bytes) |
| 0x22 | reserved word |
| 0x24 | seglist (stored by LibInit) |
| 0x28 | SysBase (stored by LibInit) |
| 0x2c | lhbase (OpenLibrary("lh.library",1) result) |

## XpkInfo (code hunk)

xi_XpkInfoVersion=0, xi_LibVersion=1, xi_MasterVersion=1,
xi_ModesVersion=0; xi_Name "LHLB"; xi_LongName "Fast and good
compression usable for all data"; xi_Description "preprocessor
for lh.library"; xi_ID 'LHLB'; xi_Flags=9; MaxPkInChunk=0x8000;
MinPkInChunk=0; DefPkInChunk=0x8000; msgs NULL; DefMode=100;
ModeDesc -> XpkMode.

## XpkMode (code hunk, RT_ENDSKIP lands here)

xm_Next=0, xm_Upto=100, xm_Flags=1 (XPKMF_A3000SPEED),
xm_PackMemory=0x12c40 (76864), xm_UnpackMemory=0x1194 (4500),
xm_PackSpeed=140, xm_UnpackSpeed=1043, xm_Ratio=45,
xm_ChunkSize=0, xm_Description="normal".

## XpkSubParams

xsp_InBuf +0x00, xsp_InLen +0x04, xsp_OutBuf +0x08,
xsp_OutBufLen +0x0c, xsp_OutLen +0x10, xsp_Sub[4] +0x34.
Sub state: `xsp_Sub[0]` = lh control block, `xsp_Sub[1]` =
0x9000 scratch buffer (pack only).

## lh.library vectors used

| LVO | usage |
|-----|-------|
| -30 | allocate control block (d0 = mode: 0 pack / 1 unpack) |
| -36 | free control block (a0) |
| -42 | pack (a0 = block {in,len,outbuf,outlen}) |
| -48 | unpack (a0 = block, same layout) |

The lh control block takes the chunk parameters as four longwords
at offsets 0/4/8/12.  Names are inferred from use -- lh.library
1.8 is itself in the collection (`libraries/lh_1.8.library`).

## Strings

`xpkLHLB.library`, `xpkLBLB 1.1 (5.4.98)\r\n` (the "LBLB" typo is
in the shipped idstring), `lh.library`, `LHLB`, `Fast and good
compression usable for all data`, `preprocessor for lh.library`,
`normal`.
