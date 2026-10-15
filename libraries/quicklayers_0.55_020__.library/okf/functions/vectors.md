---
file: vectors
---
# Vectors (4 abs-long @h0+0xc0)

-6 Open +0x2b4 (opencnt@lib+0x20, gate bit3@lib+0xe) |
-12 Close +0x2c4 (deferred expunge) | -18 Expunge +0x2d4
(stub: moveq0/rts) | -24 +0x2d4 same stub. Only the
standard 4 vectors — this is a shim; functionality is via
binary patching, not its own API.

initfn @h0+0xf8: opens 3 deps v39 (strings at h0+0x9c/
0x7b/0x8c — graphics/layers/utility family), FindName for
the target resident module, AllocMem + CopyMem the module
into RAM, scans it for 0x4eba (jmp abs) entries and repoints
them at h1 replacement routines via the 12-record table.
