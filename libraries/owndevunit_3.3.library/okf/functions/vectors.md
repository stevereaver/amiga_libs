---
file: vectors
---
# Vectors

11 absolute-long vectors @h0+0xa8 -> h0/h2:
-6 Open ->h2+0x138 | -12 Close ->h2+0x156 | -18 Expunge ->h2+0x180
| -24 ->h0+0x126 | -30 OwnDevUnit ->h2+0x208 | -36 ->h2+0x23a |
-42 ->h2+0x26c | -48 ->h2+0x302 | -54 ->h2+0x35a |
-60 ->h0+0x12a | -66 ->h2+0x39c.

Attempts use exec semaphores (-564/-570 Obtain/Release) and
timer.device for retry timeouts ('unit device not supplied',
'unable to open timer.device'). Expunge -> 0.
