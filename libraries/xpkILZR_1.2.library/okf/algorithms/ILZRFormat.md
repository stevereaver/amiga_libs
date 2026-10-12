---
type: Algorithm
title: xpkILZR 1.2 stream format
---

# Stream format — MSB-first bit sequence

```
stream := <inlen:u16>{ token }*
token  := '1' byte8                 literal
       |  '0' pos(w) len4           match, len = len4+3
w      := position width, starts 8, grows when the cursor
          passes base + 2^w  (pack: in cursor; unpack: out)
pos    := ABSOLUTE position (not distance) — decoder copies
          from out+pos, emitter writes the candidate index
```

- pack out bound: flag-byte cursor reaching
  `OutBuf + OutBufLen` → `-17` (checked on byte rollover)
- OutLen = bytes produced (`w - out + 1` — the current
  flag byte counts even when only partially filled)
- unpack: header `d7 > OutBufLen` → `-10`; then writes
  the declared len into `xsp_OutBufLen` and emits exactly
  `d7` bytes; a match may run past `d7` mid-copy
- width bump is the same on both sides (`cursor > base+2^w`
  → `w++`), so the streams line up; 1.2 emits at most
  w=15-bit positions for 16K chunks
- emitted match length is clamped by `runcap` (≤17
  mid-stream; the finder can produce 18 but the emit
  clamps it — `len-3` only ever carries 0..14)

## Differences vs the 1.5 build

Same family format, but 1.5's emit/parse plumbing differs
(lazy single 0x18004 workmem, -14 out-bound error, different
descriptor values, no private-copy lifecycle).
