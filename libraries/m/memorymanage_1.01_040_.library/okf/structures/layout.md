# Structures — memorymanage.library 1.01

## Library base (dataSize = 0x53)

```
+0x00  struct Library (OpenCnt at +0x20, NegSize +0x12, PosSize +0x14)
+0x22  seglist (BPTR)
+0x26  root node ptr | adopted SRP (when +0x52 != 0)
+0x2a  trailer freelist head
+0x2e  region scratch buffer (0x100 AllocVec, {start,len} pairs)
+0x32  saved MMU block, 30 bytes written by sv_readregs:
         +0 URP +4 SRP +8 DTT0 +12 DTT1 +16 ITT0 +20 ITT1
         +24 TC.w  +26 MMUSR.l (long store spills into +28/29)
+0x4a  saved TC word (bit15 = MMU enabled at attach)
+0x4c  saved MMUSR word
+0x4e  pad (written by the long MMUSR store)
+0x50  attach refcount (word)
+0x52  active flag: 0xff => adopted a live SRP, we did not build tables
```

## Page-table block trailer (16 bytes after each table)

Root and mid tables: alloc 0x410, table at `(p+0x1ff)&~0x1ff`,
trailer at table+512.  Leaf tables: alloc 0x210, table at
`(p+0xff)&~0xff`, trailer at table+256.

```
+0  next trailer (freelist at base+42)
+4  alloc base (FreeVec target)
+8  slot ptr (address of the parent desc this table replaced)
+12 old desc value (restored into slot at detach)
```

## MMU profiles (code+0x37c / code+0x396, 26 bytes each)

Both statically identical: `{0, 0, 0x00ff4000 x4, 0x8000}` —
URP=0, SRP=0, all four TTRs disabled (0x00ff4000 has E=0),
TC=0x8000 (MMU on, 4KB pages).  MMUAttach overwrites +4 (SRP) and
+12 (DTT1) in BOTH profiles with FreeVec(regionbuf)'s return value.
