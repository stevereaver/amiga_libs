# xpkACCA 1.2 — structures & layout

## Hunk / header (verified byte-exact)

- single code hunk; entry stub `moveq #0,d0; rts` @0.
- RomTag @4: matchtag=4, EndSkip=0 (-> the stub itself, a quirk),
  RTF_AUTOINIT, ver 1, NT_LIBRARY, pri 0.
- InitTable @0x64: dataSize 0x26, functab @0x94, datatab @0x74,
  initfn @0xac.
- datatab: ln_Type=9, ln_Name, lib_Flags=6, lib_Version=1,
  lib_Revision=2, lib_IdString; `00 00` terminator.
- LibInit @0xac: stores seglist at libbase+34.

## Library base

`dataSize 0x26` = Library(34) + seglist@+34. OpenCnt at +32,
lib_Flags at +14 (bit3 = DELEXP), NegSize +16, PosSize +18.

## XpkSubParams (caller struct, a0)

| off | field |
|-----|-------|
| +0  | InBuf     |
| +4  | InLen     |
| +8  | OutBuf    |
| +12 | OutBufLen (pack: bound ref; **unpack: produced len lands here**) |
| +16 | OutLen    (pack: produced len)   |
| +28 | Mode      (<=79 turbo / >79 crawling) |
| +52 | Sub0 = workmem body (header at -4 holds alloc size) |
| +56 | Sub1 = mode flag 0/15 -> PackReset pass count 1/16   |

## Descriptor @0x678 (XpkInfo)

ver words 1,1,2,0; Name="ACCA"; LongName="Andre's Code Compression
V1.2"; Desc="Similar to RDCN, but more efficient"; ID='ACCA';
Flags=0x8009; MaxPkIn=0x7fffffff; MinPkIn=0; DefPkIn=0xffdc;
Msgs: "Crunching"/"Decrunching"/"Crunched"/"Decrunched";
DefMode=100; ModeDesc->0x6b4.

Mode list: **empty 28-byte head record** @0x6b4 (next + 6 zero
longs only — a sentinel, shorter than a full 42-byte record), then:

- @0x6d0 "turbo":   Upto 79,  Flags 1, PackMem 0x4004,  UMem 0,
  PSpeed 157, USpeed 400, Ratio 337, ChunkSize 0.
- @0x6fa "crawling": Upto 100, Flags 1, PackMem 0x48004, UMem 0,
  PSpeed 40,  USpeed 400, Ratio 400, ChunkSize 0.

## Workmem

PackChunk allocates once (first call only) `0x4004` (turbo) or
`0x48004` (crawling) bytes, MEMF_PUBLIC (flag 1 — NOT cleared);
size long stored at buf+0, body pointer (buf+4) cached in xsp_Sub0,
mode flag (0/15) in xsp_Sub1.

- turbo layout: 4096-long head table at body+0 (h*4 index),
  heads = absolute input pointers.
- crawling layout: 65536-long head table at body+0 keyed by
  h=(b0<<8)|((b1+b2)&0xff); 8192-long ring at body+0x40000 keyed
  by `pos & 0x1fff` (ADDRESS bits, not offset). All values are
  absolute pointers; dist = cur - cand.

## Reconstruction note

The C port stores `offset+1` (input-relative) instead of absolute
pointers so the same collision structure is preserved without
address-dependence: stored 0 models the original NULL head
(dist = cur-0 = huge -> walk exits). On real Amiga the original's
pack stream varies with the input buffer's load address; the C
build emits one canonical valid stream.
