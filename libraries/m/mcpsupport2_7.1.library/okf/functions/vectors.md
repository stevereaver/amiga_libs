---
file: vectors
---
# Vectors

18 live LVOs (-6 .. -108 minus), absolute functab@h0+0x88;
four entries are literal 0 -> h0+0 `moveq#-1/rts` stub.

-6 open +0x14a, -12 close +0x158, -18 expunge +0x166,
-24 0-hole, -30 +0x1b4, -36 +0x25a (dos-84 Open-ish),
-42 +0x380, -48 +0x2f6, -54 +0x4f6, -60 +0x588,
-66 +0x6aa, -72 +0x7d4, -78 +0x95c, then 0-holes +0xdb4
0-holes for the tail slots.

Exec -132/-138 (FindName/RemakeName-family) and dos -84
observed; init opens dos.library v37 + utility.library v36.
