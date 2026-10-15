---
file: vectors
---
# Vectors

21 absolute-long vectors @h0+0xc4:
-6 Open 0x348 | -12 Close 0x356 | -18 Expunge 0x370 |
-24 0x42a | -30..-126 disk-codec funcs (0x452 0x51c 0x572
0x618 0x6ea 0x902 0x454 0x62a 0xb10 0xc50 0xd96 0xe62 0xecc
0xee8 0xf1e 0xf5a 0xf8a).

Oracle-visible: initfn calls exec -498/-108 (lib version
checks); vectors hit exec -456 (timer-ish IO) and return
sentinel patterns (0xaaaaaaaa/0x55555555 for a bit-pattern
op). Massive deterministic unmapped scan during one vector
(73,587,352 invalid reads counted, orig==rebuild).
