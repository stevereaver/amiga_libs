---
file: vectors
---
# Vectors (word-offset functab @h0+0x94)

-6 Open +0xb4 | -12 Close +0xc2 | -18 Expunge +0xd4 |
-24 zero-hole -> +0 stub | -30 XpkPackerInfo +0x112
(PackerInfo @CODE+0xe9a: "Shrink"/"Shrink V3.0", 'SHR3',
flags 0x28009, 7 modes upto 14..100) |
-36 XpksPackChunk +0x18e | -42/-60 ctx-free/reinit +0x11a
| -48 ctx re-init +0x132 | -54 XpksUnpackChunk +0x76e.

Identical SHR3 wire format to the 020 build — the same
32B 'ABCD'*8 test vector packs to the identical 16B stream.
Mode speeds differ (pspd 6-9/uspd 18-22 vs 7-10/20-24).
