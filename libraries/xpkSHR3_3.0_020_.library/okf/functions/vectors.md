---
file: vectors
---
# Vectors (word-offset functab @h0+0x90)

-6 Open | -12 Close | -18 Expunge | -24 stub->0 |
-30 XpkPackerInfo -> XPKPACKERINFO @h0+0xe02:
  "Shrink"/"Shrink 020+ V3.0", sign 'SHR3', flags 0x28009,
  7 mode descriptors (worst..best, upto 14..100);
-36 XpksPackChunk — SHR3 encoder; incompressible input
  returns -17 (encoder margin bail); real pack produces
  deterministic 16B stream for 32B 'ABCD'*8 input;
-42 XpksFreeChunk (ctx free) | -48 ctx (re)init |
-54 XpksUnpackChunk — two decoder flavours selected by
  xsp+0x14 bit1: ring-buffer (flags 0) and literal (flags 2);
  header >=2 rejected with -26 | -60 stub->0.

Runtime: pack ctx allocations 3.4MB + 86KB + 2016B observed;
deferred expunge while opencnt>0 (flags 0x0e), real expunge
on final close.
