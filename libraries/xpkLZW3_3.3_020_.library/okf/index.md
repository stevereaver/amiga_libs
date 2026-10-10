# xpkLZW3.library 3.3 (020) -- OKF Index

- **Binary:** `binary/xpkLZW3_3.3(020).library` (1264 bytes,
  sha256 e313b7a3, single code hunk, 1144-byte image)
- **ID string:** `$VER: xpkLZW3 V3.3 (1 Oct 2013) by Niels Froehling`
- **RomTag:** `RTF_AUTOINIT`, version 1, `NT_LIBRARY`, pri 0
- **Library base (dataSize 0x26):** Library header + seglist @ +0x22
- **lib_Version/Revision:** 3/3 (V3.3)
- **Requires:** 68020+ (unaligned word/long access, see findings)
- **Reconstruction:** `source/` builds with `m68k-amigaos-gcc -m68000`
  (two-pass build for the word-offset functab)

## Purpose

XPK compression sublibrary, "LZ-Welsh (not Welch) 020+ V3.3".
Despite the 'LZW3' descriptor ID this is an LZ77 variant in the
same family as xpkSLZ3 (greedy hash-chain matcher), not LZW.
Lazily allocates a 524,292-byte workmem at the first
XpksPackChunk call and holds it in `xsp_Sub[0]`.

## Public vectors

| LVO | Name | Notes |
|-----|------|-------|
| -6 | LibOpen | OpenCnt++, clears DELEXP |
| -12 | LibClose | OpenCnt--, delayed expunge |
| -18 | LibExpunge | Remove + FreeMem(neg+pos) |
| -24 | _start | ExtFunc -> entry stub, returns 0 |
| -30 | XpksPackerInfo | -> static XpkInfo/XpkMode @ hunk+0x36c |
| -36 | XpksPackChunk | LZ encoder (greedy, len 4..259, dist <= 0xffff) |
| -42 | XpksPackFree | FreeMem(sub-4, buf[0]) if xsp_Sub set |
| -48 | XpksPackReset | zero-fill hash table (see findings) |
| -54 | XpksUnpackChunk | decoder |
| -60 | _start | XpksUnpackFree -> entry stub, returns 0 |

## Descriptor

XpkInfo v1/lib3/master2, name "LZ-Speeder", longname
"LZ-Welsh (not Welch) 020+ V3.3", desc "LZW2 compatible,
better compressing", ID 'LZW3', flags 9 (PK_CHUNK|UP_CHUNK),
max/def chunks 0x7fffffff/0x50000, msgs "Annihilate"/
"Reanimate"/"Oh god, It is done!"/"Hehe, fast hew.",
defmode 100.  XpkMode: upto 100, flags 1, PackMemory
0x80004, PackSpeed 22, UnpackSpeed 600, ratio 333.
A "cremation" string sits in the descriptor block
unreferenced (dead data).
