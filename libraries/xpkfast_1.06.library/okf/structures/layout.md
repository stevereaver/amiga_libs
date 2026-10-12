# xpkFAST 1.06 structures

## XpkSubParams (xsp)

| off  | field         | notes                                   |
|------|---------------|-----------------------------------------|
| 0x00 | xsp_InBuf     |                                         |
| 0x04 | xsp_InLen     |                                         |
| 0x08 | xsp_OutBuf    |                                         |
| 0x0c | xsp_OutBufLen | read by neither packer nor unpacker     |
| 0x10 | xsp_OutLen    | set by PackChunk on success             |
| 0x14 | xsp_Flags     |                                         |
| 0x18 | xsp_Number    |                                         |
| 0x1c | xsp_Mode      | <80 speedy / >=80 crawling (unsigned)   |
| 0x20 | xsp_Password  | unused                                  |
| 0x24 | xsp_LibVers   |                                         |
| 0x28 | xsp_Arg[3]    |                                         |
| 0x34 | xsp_Sub[4]    | Sub[0]=workmem ptr, Sub[1]=alloc size   |

## Workmem

- speedy, size 0x10000: u32[16384] hash table at base,
  pre-filled with `in_end`.
- crawling, size 0x44000: u32[65536] hash table effectively
  reachable only at `work+0 .. +0x40000` (negative-biased index
  wraps `0xfffc0000|h<<2` onto base `work+0x40000`;
  `work+0x10000..+0x40000` is dead space), plus u32[4096]
  chain table at `work+0x40000`.  The first 0x11000 longwords
  (both tables) are filled with `in-4096` per pack.

## Library base

`struct Library` (34 bytes) + execbase at **34**, seglist at
**38** — dataSize 0x4a.  Note the init order: LibInit stores
execbase at +34 BEFORE seglist at +38.

## InitStruct / datatab quirk

initstruct at code+0x58: `{dataSize 0x4a, functab 0x68,
datatab 0x94, initfunc 0xb4}`.

The datatab (code+0x94) is nonstandard:

```
a0 0c  09 00          byte op @+0x0c: writes 9 at lib+12 --
                      inside the ln_Name pointer (ln_Type is at
                      +8); the 0x80 0x0a op next overwrites it
80 0a  <libname>      long op @+0x0a: ln_Name
a0 0e  06 00          byte @+0x0e: lib_Flags = 6
90 14  00 01          word @+0x14: lib_Version = 1
90 16  00 06          word @+0x16: lib_Revision = 6
80 18  <idstr>        long @+0x18: lib_IdString
00 00  00 00          end
```

On-disk bytes confirmed verbatim; `xpkfast_lib.s` reproduces
them byte-for-byte including the `a0 0c` offset-12 quirk.
Post-init observed fields: +0x0c holds 0x001e/0x0600 overlays
from the byte/word writes, +0x14=1, +0x16=6.

## XpkInfo descriptor (code+0x1dc)

`{xpkvers 1, libvers 1, mastervers 2, modesvers 0,
name "fasTcinator", long "FAST V1.06 alias WOOP or LZRW++",
desc "LZ77-family, windowsize: 4095, no quotecount, 2 streams",
id 'FAST', flags 0x8009, maxchunk 0x7fffffff, minchunk 0,
defchunk 0x10000, packmsg "tieing", unpackmsg "untieing",
packedmsg "compressed", unpackedmsg "decompressed",
defmode 0x32 (50), reserved[6], modedesc}`

Mode chain (XpkMode: `{next.l, upto.l, flags.l, packmem.l,
unpackmem.l, packspeed.l, unpackspeed.l, ratio.w, pad.w,
name[10]}` — 32+10 bytes):

- m1 "speedy":   upto 79,  flags 1, packmem 0x10000,
  unpackmem 0, pk 0x1ac / unpk 0x41f, ratio 0x147
- m2 "crawling": upto 100, flags 1, packmem 0x44000,
  unpackmem 0, pk 0x46  / unpk 0x448, ratio 0x189, next NULL

Descriptor + strings + mode chain verified byte-identical
modulo relocated pointers (emulated reads, both builds).
