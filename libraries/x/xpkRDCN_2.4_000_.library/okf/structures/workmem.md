# xpkRDCN 2.4 — Structures

## Library base (dataSize 0x26)

```
+0x00  struct Library (0x22)
+0x22  ULONG seglist      (stored by LibInit)
```

## XpkSubParams (in a0 for pack/unpack vectors)

```
+0x00  APTR  xsp_InBuf
+0x04  ULONG xsp_InLen
+0x08  APTR  xsp_OutBuf
+0x0c  ULONG xsp_OutBufLen
+0x10  ULONG xsp_OutLen        (result, written by packers)
+0x14  ULONG xsp_Flags
+0x18  ULONG xsp_Number
+0x1c  ULONG xsp_Mode          (dispatch: <=79 speedy, >=80 crawling)
+0x20  STRPTR xsp_Password
+0x24  UWORD  xsp_LibVersion + pad
+0x28  ULONG  xsp_Arg[3]
+0x34  ULONG  xsp_Sub[0]       work memory (after size prefix)
+0x38  ULONG  xsp_Sub[1]       mode flag: 0 speedy / 15 crawling
```

## Pack work memory

- speedy:   `AllocMem(0x4004)` — 4B size prefix + hash table
  `ULONG[4096]` at Sub[0].
- crawling: `AllocMem(0x48004)` — size prefix + hash table
  `ULONG[65536]` at Sub[0] + chain table `ULONG[8192]` at
  Sub[0]+0x40000.
- Chain slot index is `pointer & 0x1fff` — the raw ADDRESS masked to
  13 bits, not the position within the input. Aliasing is inherent
  (two addresses 8KB apart share a slot); entries store the previous
  hash head pointer, forming hash->prev chains.
- PackReset zeroes only the hash table(s): 0x4000 B (speedy) or
  0x40000 B (crawling). The chain table is never cleared.

## XpkInfo descriptor (file 0x5fe)

```
xiVer=1 libVer=2 master=2 modes=0
Name="RDCN" LongName="Ross Data Compression V2.4"
Desc="Very fast, but yet efficient packer"
ID='RDCN' Flags=0x8009 MaxPk=0x7fffffff MinPk=0 DefPk=0xffdc(-36)
PackMsg=UnpackMsg=PackedMsg=UnpackedMsg=0 (all NULL)
DefMode=100  ModeDesc->mode0
mode0 "speedy":   next->mode1 upto=79  flags=1 packmem=0x4004
                  unpackmem=0 pspeed=0x83 uspeed=0x1e0 ratio=0x149
mode1 "crawling": next=0      upto=100 flags=1 packmem=0x48004
                  unpackmem=0 pspeed=0x27 uspeed=0x1ef ratio=0x18e
```

Trailing bytes at hunk end: `72 00 00 08` (linker tail garbage,
reproduced verbatim via endmodule.s).
