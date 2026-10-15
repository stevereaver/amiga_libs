---
file: vectors
---
# Vectors (12 abs-long @h0+0xca)

-6 Open +0x1be | -12 Close +0x1cc | -18 Expunge +0x1e0 |
-24 NULL (hole) | -30 +0x236 | -36 +0x30c | -42 +0x41c |
-48 +0x436 | -54 +0x44e | -60 +0x48a | -66 +0x58e |
-72 +0x5b0.

Under the generic harness: open x2 bumps count, vectors
execute with exec -564/-570 (semaphore) calls, -72 frees
via FreeMem, close->deferred-expunge->real expunge on
final close. initfn stores exec seglist ptr at lib+0x22.
