# Structures

## Library base (dataSize 0x38 = 56)

| off | field |
|-----|-------|
| 0x00 | struct Library (34 bytes, hand-initialised) |
| 0x22 | rb_SegList |
| 0x26 | rb_Fixup -- 18-byte region at +0x26..+0x37; the
        far-data fixup writes relocated pointers at
        base+0x30+off[i] (never used: count = 0) |

## InitTable (hunk2, for the private loader)

```
{ libSize = 0x38, funcTable -> hunk0+0x38c,
  dataTable = 0, initRoutine -> hunk0+0x20 }
```

funcTable = 6 absolute longs: Open@0xc4, Close@0xd6,
Expunge@0x100, 0, Fn1@0x1c8, Fn2@0x290.

## hunk1 -- SAS/C far-data fixup table

`{ count, off[0], ... }`: for each off,
`*(base+0x30+off) += base+0x30`.  Shipped content is two
zero longs -- count 0, a template that never fires.

## hunk3 -- global stashes

`{ SysBase, intuition.library base }`.  Every library
routine reloads a6 from hunk3+0 for exec calls and
hunk3+4 for intuition calls -- the SAS/C far-data
convention.

## hunk4 -- WarpCore base

`{ WarpCoreBase }`, written from `*(ULONG*)((UBYTE*)port+46)`
on every proxied call.  The WarpCore port is a custom
message port; +46 is 6 bytes past the standard MsgPort --
an application-defined field holding a mini jump-table
base address whose -30/-36 slots take the proxied
requester arguments.

## Service protocol

- semaphore: `FindSemaphore("ReqAttack SubLibrary")`,
  `AttemptSemaphoreShared` (shared read lock across the
  port lookup + call), `ReleaseSemaphore`.
- port: `FindPort("ReqAttack Warp Core")` -> port+46 =
  WarpCore function-table base.
- contract: WarpCore slot returns -3 => proxy falls back
  to the real intuition function.
