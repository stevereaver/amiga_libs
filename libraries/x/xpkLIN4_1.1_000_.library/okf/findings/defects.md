---
file: defects
---
# Findings

- PackerInfo msg0 is the misspelled `Comressing` (upstream typo,
  preserved verbatim).
- Buffers <= 0x40ish bytes return XPKERR (-17 0xffffffef); pack of
  ~<64B inputs is refused.
- `allocmem` called with size 0x100156 on mode paths — the library
  preallocates a ~1MB work pool.
- Reserved LVOs -24/-48 vector to the hunk+0 stub (moveq #0 / rts).
- Passworded streams embed a header hash; wrong-password unpack
  returns XPKERR (-32 0xffffffe0) identically.
