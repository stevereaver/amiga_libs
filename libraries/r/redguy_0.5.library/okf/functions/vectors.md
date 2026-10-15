---
file: vectors
---
# Vectors (16 abs-long @+0x1178)

-6 Open +0x6e | -12 Close +0xb8 | -18 Expunge +0xec |
-24 +0x12c | -30..-96 at +0x11e2..+0x12c4.

Vectors do closelib/freemem(2024) cleanups + many small
invalid reads at negative addresses (lib-relative
negative table walk — 1827 deterministic accesses).
