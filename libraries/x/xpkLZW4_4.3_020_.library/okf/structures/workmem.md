# packer workmem -- 0x80004 bytes, AllocMem(0x80004, 0) lazily

    buf+0x00000  ULONG size = 0x80004   (PackFree's FreeMem length)
    sub+0x00000  ULONG head[65536]      newest position per hash key
    sub+0x40000  ULONG chain[65536]     previous same-key position,
                                        slot = position & 0xffff

xsp_Sub[0] = buf + 4 = "sub".  Entries are absolute pointers, not
offsets -- the workmem is not relocatable but never needs to be.

## key

    key = b0<<8 | ((b1 + b2) & 0xff)

`move.w (a2),d1` then `add.b 2(a2),d1`: the third byte adds into
the LOW BYTE only -- no carry into b0's half.  head[] is reached
through `d1 = 0xffff0000|key` scaled *4 off a base at sub+0x40000,
i.e. a wrapped negative index landing at sub+0 + key*4.

## reset

PackReset fills exactly 65536 longs starting at sub+0x40000
counting DOWN with pre-decrement movem stores = the head table
only.  (xpkLZW3 3.3's fill ran 68 bytes low and zeroed buf[0],
breaking PackFree -- fixed here.)  chain[] is never cleared: slots
hold garbage until first overwritten, but the signed distance
bound (`cur - cand >= 0x10000` exits) keeps a stale/garbage entry
from being followed past the 64 KB window... unless it points
FORWARD, in which case the bge doesn't fire -- see findings.
