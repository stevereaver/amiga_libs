# xpkSLZ3.library 1.3 (000) -- OKF Index

- **Binary:** `binary/xpkSLZ3_1.3(000).library` (1188 bytes, single code hunk, 1084-byte hunk image)
- **ID string:** `$VER: xpkSLZ3 V1.3 (1 Oct 2013) by Niels Froehling`
- **RomTag:** `RTF_AUTOINIT`, version 1, `NT_LIBRARY`, pri 0
- **Library base (dataSize 0x26):** Library header + seglist @ +0x22
- **Author:** Niels Froehling; algorithm per Adisak Pochanayon's workshop
- **Reconstruction:** `source/` builds with `m68k-amigaos-gcc -m68000`
  (two-pass build for the word-offset functab)

## Purpose

XPK compression sublibrary implementing "Simple & Fast LZSS"
(`fastLZ`/`FastSLZ`).  Lazy-allocates a 278,532-byte workmem
at the first XpksPackChunk call and holds it in `xsp_Sub[0]`.

## Public vectors

| LVO | Name | Notes |
|-----|------|-------|
| -6 | LibOpen | OpenCnt++, clears DELEXP |
| -12 | LibClose | OpenCnt--, delayed expunge |
| -18 | LibExpunge | Remove + FreeMem(neg+pos) |
| -24 | _start | ExtFunc -> entry stub, returns 0 |
| -30 | XpksPackerInfo | -> static XpkInfo/XpkMode @ hunk+0x368 |
| -36 | XpksPackChunk | LZSS encoder (greedy, len 3..17, dist <= 4095) |
| -42 | XpksPackFree | FreeMem(sub-4, buf[0]) if xsp_Sub set |
| -48 | XpksPackReset | zero-fill hash table (see findings) |
| -54 | XpksUnpackChunk | decoder |
| -60 | _start | XpksUnpackFree -> entry stub, returns 0 |

## Descriptor

XpkInfo: v1/lib1/master2/modes0, name "FastSLZ",
longname "Simple & Fast LZSS V1.3", desc "Based upon a
workshop of Adisak Pochanayon (\xae)", ID 'SLZ3', flags 9
(PK_CHUNK|UP_CHUNK), max/def chunks 0x7fffffff/0x10000,
defmode 100.  XpkMode: upto 100, flags 1, PackMemory 0x44004,
PackSpeed 54, UnpackSpeed 646, ratio 392, "fastLZ".
