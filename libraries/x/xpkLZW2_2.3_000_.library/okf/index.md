# xpkLZW2.library 2.3 -- OKF Index

- **Binary:** `binary/xpkLZW2_2.3_000_.library` (1348 bytes,
  sha256 24f95b2d0d9bcdd5, single code hunk, 0x4cc-byte image)
- **ID string:** `$VER: xpkLZW2 V2.3 (1 Oct 2013) by Niels Froehling`
- **RomTag:** `RTF_AUTOINIT`, version 1, `NT_LIBRARY`, pri 0
- **Library base (dataSize 0x26):** Library header + seglist @ +0x22
- **lib_Version/Revision:** 2/3 (V2.3)
- **Reconstruction:** `source/` builds with `m68k-amigaos-gcc -m68000`
  (two-pass build for the word-offset functab)

## Purpose

XPK compression sublibrary, "LZ-Welsh (not Welch) V2.3".
Despite the 'LZW2' descriptor ID this is an LZ77 variant in
the same family as xpkSLZ3/xpkLZW3 (greedy hash-chain
matcher), not LZW -- the direct predecessor of the V3.3
"020+" rebuild.  Lazily allocates a 327,684-byte workmem at
the first XpksPackChunk call and holds it in `xsp_Sub[0]`.

## Public vectors

| LVO | Name | Notes |
|-----|------|-------|
| -6 | LibOpen | OpenCnt++, clears DELEXP |
| -12 | LibClose | OpenCnt--, delayed expunge |
| -18 | LibExpunge | Remove + FreeMem(neg+pos) |
| -24 | _start | ExtFunc -> entry stub, returns 0 |
| -30 | XpksPackerInfo | -> static XpkInfo/XpkMode @ hunk+0x3aa |
| -36 | XpksPackChunk | LZ encoder (greedy, len 4..259, dist <= 0xffff) |
| -42 | XpksPackFree | FreeMem(sub-4, buf[0]) if xsp_Sub set |
| -48 | XpksPackReset | zero-fill hash table (see findings) |
| -54 | XpksUnpackChunk | decoder |
| -60 | _start | XpksUnpackFree -> entry stub, returns 0 |

## Descriptor

XpkInfo v1/lib2/master2, name "LZ-Speeder", longname
"LZ-Welsh (not Welch) V2.3", desc "LZSS with big window
(64 KB), slow packing and fast decrunch", ID 'LZW2', flags 9
(PK_CHUNK|UP_CHUNK), max/def chunks 0x7fffffff/0x50000, msgs
"Annihilate"/"Reanimate"/"Oh god, It is done!"/
"Hehe, fast hew.", defmode 100.  XpkMode: upto 100, flags 1,
PackMemory 0x50004, PackSpeed 32, UnpackSpeed 556,
ratio 323, and -- unlike V3.3 -- the inline
`xm_Description[10]` field is populated: it literally reads
"cremation".

## Relationship to xpkLZW3 3.3

Same stream format, same flag-group framing, same token
encoding, same workmem idiom.  V2.3 differs in:

- hash mask `0x3fff` (16K entries) vs `0xffff` (64K);
  workmem 0x50004 vs 0x80004;
- lazy insertion: only cur+1..cur+3 and cur+L are hashed
  after a match of length L (V3.3 rehashes every position);
- PackReset underflow is 5,040 bytes (V3.3 is only 68);
- V2.3's decoder keeps every access byte-wise
  (`moveb`/`dbf`) -- no 020+ requirement, runs on a plain
  68000.

## Exec LVO inventory

-198 AllocMem (lazy workmem), -210 FreeMem (Expunge +
PackFree), -252 Remove (Expunge).  Nothing else.
