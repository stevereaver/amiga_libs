# Shipped defects and quirks (xpkSLZ3 1.3)

## 1. PackReset heap underflow (~15 KB)

The down-fill starts at `sub+0x40000` (hash top) and writes
277,212 bytes, but the hash is only 262,144 bytes: it runs
~15,068 bytes BELOW the workmem block into the previous heap
object.  Reproduces on every first PackChunk / PackReset.

## 2. Chain ring never initialised

The fill never reaches `sub+0x40000..0x44004`.  Chain
entries start as AllocMem garbage; the `dist > 0xfff`
filter and the byte-compare gate keep them from producing
wrong output, but garbage pointers within 4 KB of the
input could still be dereferenced for the quick-check read.

## 3. OOB input reads

Seed reads `p[1]`/`p[2]` unconditionally (~2 bytes past end
on the final positions); the 16-compare unrolled match scan
reads up to ~17 bytes past `inbuf+inlen` on tail matches.

## 4. Output bound checked after the write

`cmpal a4,a6` (outbuf+inlen) fires AFTER each item is
emitted -> up to a 2-byte overrun before -17 is returned,
and `xsp_OutBufLen` is ignored entirely.

## 5. xsp_OutLen not written on -17, never by unpack

PackChunk only stores OutLen on success; the decoder never
touches it at all (no output bound checking either -- the
stream is trusted).

## 6. PackFree double-free window

xsp_Sub[0] is not cleared after FreeMem; a second
XpksPackFree would FreeMem the same block again.

## 7. Dead SysBase reload in LibExpunge

`moveal a5@(36),a6` (0x168) is overwritten by
`moveal 0x4,a6` before use.
