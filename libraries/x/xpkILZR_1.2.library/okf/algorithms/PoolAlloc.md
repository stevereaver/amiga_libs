---
type: Algorithm
title: xpkILZR 1.2 pool sub-allocator (LAB_0069)
---

# suballoc — pool-style allocator over AllocMem

`a4 = base+0x3c`; fields: minsize +0xbc (base+0xf8 = 0x1000),
ioerr +0xcc (base+0x108), memflags +0xd0, freelist +0xd4.

```
if (req == 0) { ioerr = 22; return 0; }
req = (req + 3) & ~3
actual = max(req, minsize)
blk = AllocMem(actual + 20, memflags)      /* flags = 0 */
if (!blk) { ioerr = 12; return 0; }
blk[0] = freelist;  freelist = blk         /* link head   */
blk[1] = actual                            /* size        */
blk[3] = memflags
slack = actual - req
if (slack && slack != 4) {
    blk[2] = slack - 4
    blk+16.w = 0x8000                      /* marker      */
    blk+18.w = req>>2                      /* req words   */
    (blk+20+req).w   = req>>2              /* trailer     */
    (blk+22+req).w   = (slack>>2)|0x8000
} else {
    blk[2] = 0
    blk+16.w = 0x8000
    blk+18.w = (actual>>2)|0x8000
}
return blk + 20
```

Every call makes a FRESH OS allocation; blocks are chained
onto the freelist but nothing ever walks or frees it —
the pool only grows.  For the two codec calls
(0x10000 / 0x8024) minsize=0x1000 never kicks in and
slack is 0/4 → the `else` branch runs (`blk[2]=0`,
marker + `size|0x8000` at +16/+18).

ioerr codes: 22 = zero request, 12 = AllocMem failure.
