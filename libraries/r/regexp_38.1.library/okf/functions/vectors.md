---
file: vectors
---
# Vectors (8 abs-long @h1+0x10)

-6 Open ->h0+0x3c | -12 Close ->h0+0x54 |
-18 Expunge ->h0+0x76 | -24 stub ->h0+0xc2 |
-30 ->h0+0x2a8 | -36 ->h0+0x13c | -42 ->h0+0x906 |
-48 ->h0+0xdf4.

initfn @h0+4 opens dos.library v37. -30 does
exec -684 + a lib2 (dos) call; -36 calls exec -690;
-42 calls lib2 -462 with odd args (regex compile path).
All deterministic, 0 invalid accesses.
