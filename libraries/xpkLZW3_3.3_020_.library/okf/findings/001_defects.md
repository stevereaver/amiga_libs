# Shipped defects and quirks (xpkLZW3 3.3)

## 1. PackReset underflow zeroes the AllocMem size -> 512KB leak

The down-fill covers sub+0x40000-68 .. sub+0x40000, i.e. it
writes 68 bytes below the workmem base -- including buf[0],
the size word PackFree passes to FreeMem.  After any
PackReset (which PackChunk calls every time), PackFree
calls FreeMem(ptr, 0): the entire 524KB workmem leaks.
The fill also touches ~64 bytes under the allocation.

## 2. Chain ring never initialised

The fill stops at sub (hash bottom); the 256KB chain ring
at sub+0x40000 keeps AllocMem garbage.  The dist>=64KB
filter and byte-verify catch most garbage entries, but a
garbage pointer within 64KB of the input can still be
dereferenced by the compare reads.

## 3. 68020+ requirement (unaligned access)

Flag-long stores (`movel`) land on word-aligned slots and
match tokens are `movew`-written at arbitrary parity --
both are address errors on 68000/68010.  The "020+" in the
longname is a hard requirement, not a recommendation.

## 4. Output bound checked after the write

`cmpal d4,a6` (outbuf+inlen) fires after each item -> up to
a 3-byte token overrun before -17; xsp_OutBufLen ignored.

## 5. Tail-match quick-check can read 1 byte past end

`cur[best]` with best == remaining reads in[inlen].

## 6. xsp_OutLen / double-free quirks

OutLen written only on pack success; decoder never writes
it.  PackFree leaves xsp_Sub set -> repeat call double-frees
(with the size already zeroed, FreeMem(ptr,0)).

## 7. Dead string

"cremation" at hunk+0x3e4 is referenced by nothing.
