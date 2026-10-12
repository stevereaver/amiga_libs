# mhimpegit.library 4.0 — behavior notes

## What the library is

A thin registry/dispatcher over `prelude.library` v4 (product name
"MPEGit", author Thomas Wenzel, May 2022). It wraps a per-object list of
24-byte "event" records and forwards tag calls to prelude vectors. All
work happens inside prelude; this lib is bookkeeping + glue.

## Prelude tag map

| tag | role |
|---:|---|
| 0x80000032 | Create arg0 (a0) |
| 0x80000033 | Create arg1 (d0) |
| 0x8000003a | Dispatch op1: value clamped to 100 |
| 0x8000003b | Dispatch op6: scaled `15·min(v,100)/50` |
| 0x8000003c | Dispatch op3: scaled |
| 0x8000003d | Dispatch op5: scaled |
| 0x8000003f | Create default 100; Dispatch op0: clamped |

The tags are private prelude IDs (0x80000000+ user-tag range).

## Prelude flag

`*(prelude+0x8e)+0x10` is a ULONG the wrapper treats as an in-flight
depth: Create and Drain clear it; Append calls prelude@-60 immediately
when nonzero (and marks the node sent); Pop refuses when flag >= count;
Iterate sends prelude@-60 for every unmarked node; Drain calls
prelude@-84(d0.w=0x80) then prelude@-36, waits 35 ticks via DOS Delay,
then frees all nodes and clears flag+count.

## Classify return codes

The -78 function is an error/result classifier: specific code values map
to success(1) or version-info string pointers. Codes 1000/1001/1002
return "MPEGit", "4.0 (22.05.2022)", "Thomas Wenzel". Success classes
{1,2,3,10,11,12,20,21,30,31,40,41} and 1010 → 1; all else → 0.
