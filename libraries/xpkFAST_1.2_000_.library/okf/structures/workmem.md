# xpkFAST structures

## XpkSubParams (xsp)

| off  | field        | notes                              |
|------|--------------|------------------------------------|
| 0x00 | xsp_InBuf    |                                    |
| 0x04 | xsp_InLen    |                                    |
| 0x08 | xsp_OutBuf   |                                    |
| 0x0c | xsp_OutBufLen|                                    |
| 0x10 | xsp_OutLen   | set by PackChunk on success        |
| 0x14 | xsp_Flags    |                                    |
| 0x18 | xsp_Number   |                                    |
| 0x1c | xsp_Mode     | <79 speedy / >=79 crawling (unsigned)|
| 0x20 | xsp_Password | unused                             |
| 0x24 | xsp_LibVers  |                                    |
| 0x28 | xsp_Arg[3]   |                                    |
| 0x34 | xsp_Sub[4]   | Sub[0]=workmem(+1 long), Sub[1]=flag|

Sub[1]: 0 → speedy layout, 3 → crawling layout (the reset size
is `(Sub[1]+1)*0x10000` bytes).

## Workmem

- speedy, size field 0x10004:
  `[alloc+0]=size`, `[alloc+4 .. +0x10000)` = 16384 ULONG
  hash→position table, cleared by PackReset/PackChunk.
- crawling, size field 0x44004:
  `[alloc+0]=size`, `[alloc+4 .. +0x40000)` = 65536 ULONG
  hash table (indexed via alloc+0x40000 + negative index),
  `[alloc+0x40000 .. +0x44000)` = 4096 ULONG chain table,
  NOT cleared by PackReset.

## Library base (FastBase)

`struct Library` (34 bytes) + `seglist` at offset 34 — total
0x26, matching the AUTOINIT dataSize.

## XpkInfo descriptor (code+0x57e in the original)

Fixed part: `{version 1, libvers 1, mastervers 2, modesvers 0,
name="fasTcinator", long="FAST V1.2 alias WOOP or LZRW++",
desc="LZ77-family, windowsize: 4095, no quotecount, 2 streams",
id 'FAST', flags 0x8009, maxchunk 0x7fffffff, minchunk 0,
defchunk 0x10000, packmsg "Tieing", subpack "Compressed",
unpackmsg "Untieing", subunpack "Decompressed", defmode 100}`.

Mode list: `{ptr m1, 8×NULL}` then two blocks
`{upto, flags=1, packmem, unpackmem, pk_spd, un_spd, eff, pad,
name[]}`:

- m1 @0x5d6: upto 79, packmem 0x10004, unpackmem 0,
  0x91/0x2e4, eff 0x157, name "speedy" (10-byte field padded).
- m2 @0x600: upto 100, packmem 0x44004, unpackmem 0,
  0x37/0x2e4, eff 0x189, name "crawling".

File tail after "Decompressed\0": `00 21 e2 34` (linker
garbage reproduced by `endmodule.s`).
