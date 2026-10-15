# support.library 1.2 — memory layout

## Hunks

| # | Type | Bytes | Notes |
|---|------|------:|---|
| 0 | CODE | 2032 | everything: dead banner, RomTag, tables, code, scratch |

## CODE hunk (offsets verified against reloc + oracle)

| off   | contents |
|------:|---|
| +0x00 | dead banner-print routine (54 bytes): OpenLibrary dos/Output/Write/CloseLibrary |
| +0x38 | banner text, 46 bytes, no terminator: `"\nsupport.library v1.2 (13.03.) © 1996 by T&T\n\n"` |
| +0x66 | **packed RomTag** (unaligned longs): `4afc`, matchtag→+0x66, endskip→+0x7f0, flags=0x80, ver=1, type=9, pri=0, name→+0x80, idstr→+0x90, init→+0xb4 |
| +0x80 | "support.library"\0 |
| +0x90 | "support.library 1.2 (11 Januar 96)"\0 + pad |
| +0xb4 | InitTable: `{42, functab→+0xc4, datatab→+0x110, initfn→+0x13c}` |
| +0xc4 | functab: 18 code-absolute longs `{0x162,0x170,0x184,0x1ca,0x1ce,0x352,0x36e,0x394,0x3ae,0x3ce,0x3de,0x442,0x46e,0x47a,0x4be,0x4f4,0x520,0x68c}` + `-1` @+0x10c |
| +0x110| InitStruct datatab: `e0 08 0900` (byte+8=9), `c0 0a`+name (long+10), `e0 0e 0600` (byte+14=6), `c0 14`+`00030004` (long+20 ver/rev=3.4), `0000` end |
| +0x130| "dos.library"\0 |
| +0x13c| initfn: `moveal d0,a4` (lib), `a0`→lib+34, `a6`→a5/exec; OpenLibrary(dos,37)→lib+38; `beq` ret-0; else `movel a4,d0` ret |
| +0x162| -6 Open / +0x170 -12 Close / +0x184 -18 Expunge / +0x1ca -24 stub |
| +0x1ce| -30 SnapSize (~0x184 bytes, two-pass + repick) |
| +0x352| -36 Keep0 / +0x36e -42 Keep1 / +0x394 -48 Keep2 / +0x3ae -54 Clear2 |
| +0x3ce| -60 Invert / +0x3de -66 Gray / +0x442 -72 Scanline / +0x46e -78 Dither |
| +0x47a| -84 Swap3 / +0x4be -90 Mirror / +0x4f4 -96 SwapRB |
| +0x520| -102 Mosaic (~0x16a bytes, mathffp via a4) |
| +0x68c| -108 Transpose (~0x64 bytes) |
| +0x700| **shared scratch**: 240 bytes used by -30 pass-3, -102 s[0..11], -108 s[0..3] |
| +0x7f0| hunk end (rt_EndSkip target) |

## Library node (dsize = 42 = sizeof(struct Library) + 8)

| off | field | source |
|----:|---|---|
| +8  | ln_Type = 9 (NT_LIBRARY) | datatab |
| +10 | ln_Name → "support.library" | datatab |
| +14 | ln_Flags = 6; bit3 = delayed-expunge flag | datatab / open/close |
| +16 | lib_NegSize = 108 (18*6) | exec |
| +18 | lib_PosSize = 42 | exec |
| +20/22 | lib_Version=3, lib_Revision=4 **(quirk — idstr says 1.2)** | datatab |
| +24 | lib_IdString — never set (0) | — |
| +32 | lib_OpenCnt | open/close |
| +34 | seglist | initfn |
| +38 | DOS base | initfn |

## Relocations

29 self-relocs, all CODE→CODE: RomTag longs (+0x68..+0x7c),
InitTable entries (+0xb8..+0xc0), functab (+0xc4..+0x108),
datatab name (+0x116), code refs in banner (+0x06 lea banner-name,
+0x1c..+0x20 movel #banner/len).
