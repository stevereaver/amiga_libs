# xpkZENO 1.1 — library vectors

AUTOINIT library (`RTF_AUTOINIT`), word-offset function table
at code+0x36 (marker -1, 10 entries, -1 terminator).

## Vector map

| LVO  | Entry (orig)      | Notes                                       |
|------|-------------------|---------------------------------------------|
| -6   | 0x226 LibOpen     | `++OpenCnt; clear DELEXP; return base`      |
| -12  | 0x234 LibClose    | `--OpenCnt; expunge if DELEXP`              |
| -18  | 0x25e LibExpunge  | expunge when OpenCnt==0, else DELEXP        |
| -24  | 0x000 `_start`    | shared `moveq #0,d0; rts` stub (wrap offset)|
| -30  | 0x2a8 XpksPackerInfo | returns descriptor APTR (code+0x162)     |
| -36  | 0x30c XpksPackChunk  | LZW packer                               |
| -42  | 0x2b0 XpksPackFree   | frees pack workmem 7*D3+8                |
| -48  | 0x000 `_start`       | PackReset — no-op via entry stub         |
| -54  | 0x61a XpksUnpackChunk| LZW unpacker                             |
| -60  | 0x2e4 XpksUnpackFree | frees unpack workmem 4*Tsize+4 (**bug**: alloc is 4*Tsize+8) |

Unlike 1.2, -42 and -60 are DISTINCT routines: -60 recomputes
`4*Tsize+4` from `xsp+67` (bits) — four bytes short of the
unpacker's `4*Tsize+8` allocation.

## Resident structure (hunk offsets)

| off    | contents                                             |
|--------|------------------------------------------------------|
| 0x00   | entry stub `moveq #0,d0; rts`                        |
| 0x04   | RomTag, rt_EndSkip -> 0x85a (nop at hunk tail)       |
| 0x1e   | pad long — start of the 20-byte inittab image        |
| 0x22   | InitTable: dataSize 0x44, functab 0x36, datatab 0, initfn 0x1ba |
| 0x32   | fixup-count long = 0 (LibInit's clone loop no-ops)   |
| 0x36   | functab: `ffff` + 10 word offsets + `ffff`           |
| 0x4e   | "xpkZENO.library"                                    |
| 0x5e   | "xpkZENO 1.1\r\n"                                    |
| 0x6c   | strings: ZENO / Zeno 1.1 / LZ78 12-14bit / msgs      |
| 0xb2   | modulus table 0x1003/0x2011/0x47fb/0x87f7            |
| 0xbc   | DEAD "15 bit" mode record (old 30-byte format)       |
| 0xe4   | "14 bit" mode record                                 |
| 0x10e  | "13 bit"                                             |
| 0x138  | "12 bit" (list head, descriptor -> here)             |
| 0x162  | XpkInfo descriptor (88 bytes, to 0x1ba)              |
| 0x1ba  | LibInit                                              |

## LibInit (0x1ba)

Manual init because datatab = 0:

- `a5@(34) = a0` seglist; `a5@(8) = 9` ln_Type;
  `a5@(10) = libname`; `a5@(14) = 6` ln_Flags;
  `a5@(20) = 0x00010001` (ver 1, rev 1); `a5@(24) = idstr`.
- byte-copies 20 bytes from code+0x1e (pad long + the whole
  InitTable) into lib+48.
- fixup loop: `count = image[5]` (the long at code+0x32 = 0);
  for each of `count` offsets adds the image base to
  `image[6+i]`.  Dead code — count is always 0.
- returns libbase in d0.

## Free routines

- -42 PackFree (0x2b0): if Sub[0]: clears Sub[0], FreeMem
  recomputed `7*D3+8` where `D3 = (1<<bits)+0x800`.
- -60 UnpackFree (0x2e4): if Sub[0]: clears Sub[0], FreeMem
  `4*Tsize+4` — the shipped 4-byte under-free.
- The unpacker's alloc-fail path `bsr`s to 0x2e4 (Sub[0]==0,
  no-op) before returning -7.
