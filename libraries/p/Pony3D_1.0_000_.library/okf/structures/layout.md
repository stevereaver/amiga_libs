# Pony3D.library — structures

## Hunk map (original)

CODE hunk0 (0x3a8):

| Offset | Content                                     |
|--------|---------------------------------------------|
| +0x00  | CLI bootstrap (reqtools requester path)      |
| +0x88  | dos fallback (Output/Write idstr, 119 bytes) |
| +0xc6  | RomTag: AUTOINIT(0x80), v1, NT_LIBRARY, pri0 |
| +0xe0  | "Pony3D.library" (name)                      |
| +0xf2  | idstr "\r\n Pony3D.library 1.0 ...\r\n\r\n"  |
| +0x16a | LONG 119 (Write length for CLI path)         |
| +0x16e | InitTable {0x2a, functab, datatab, initfn}   |
| +0x17e | functab: 8 absolute longs + -1               |
| +0x1a2 | datatab (8-bit-offset InitStruct forms)      |
| +0x1c2 | LibInit (seglist→+38, SysBase→+34, +4 leak)  |
| +0x1d8 | LibOpen / +0x1e6 LibClose / +0x1fa Expunge   |
| +0x240 | reserved null stub                           |
| +0x244 | RotatePoints  / +0x306 TranslatePoints       |
| +0x32a | ProjectPoints / +0x384 Plot                  |

DATA hunk1 (0x4cc):

| Offset | Content                                     |
|--------|---------------------------------------------|
| +0x00  | "dos.library"                                |
| +0x0c  | "reqtools.library"                           |
| +0x1d  | "Pony3D.library" (requester title)           |
| +0x2c  | credits text (requester body)                |
| +0xa0  | "OKAY" (gadget text)                         |
| +0xa6  | 512-word trig table (to +0x4a6)              |

## Library private data (dataSize = 0x2a)

| Off | Field    |
|-----|----------|
| +34 | SysBase  |
| +38 | seglist  |

ln_Type is never initialized (stays 0 — MakeLibrary leaves
it, oracle-verified).  flags = 6, version 1, revision 0.

## datatab (8-bit-offset forms)

    a0 0c 09 00   byte @12 = 9   — DEAD (inside ln_Name,
                                   clobbered by next op)
    80 0a +name   long @10 = ln_Name
    a0 0e 06 00   byte @14 = lib_Flags 6
    90 14 0001    word @20 = version 1
    90 16 0000    word @22 = revision 0
    80 18 +idstr  long @24 = idstring

## Vertex list ABI

    [count]        WORD — dbf counter (count+1 processed)
    [x,y,z] × n    WORDs — rotate/translate input+output
    [x,y,z] → [sx,sy] for Project (2D out, count+1 pairs)
    [x,y] × n      WORDs — Plot input only
