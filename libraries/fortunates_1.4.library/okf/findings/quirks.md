# fortunates.library 1.4 — quirks & inconsistencies

- **LoadFile takes its path in d1, not a0**: the dos `Open` is issued
  as `movel #1005,d2; jsr` with no `a0`/`d1` setup — the caller's d1
  flows straight through. Passing a0 leaves a stale register value as
  the file name (observed in the oracle: garbage name, opens "empty"
  path). Real ABI: `LoadFile(d1=path)`.

- **FindTag list entries are stride-12**: the loop head includes
  `addql #4,a0`, so each entry occupies {4-B gap, key, val}; a dense
  {key,val} pair list never matches (skips the key). Terminator is a
  zero key; miss returns -1.

- **SysBase fetched twice, two ways**: initfn stores `*4` into _bss+0
  via `movel 4:w` (abs-short form) and *also* uses raw
  `moveal ($4).l,a6` (abs-long form, emitted `.short` to stop GAS
  canonicalizing it) for the failure `Alert`. Exec calls inside vectors
  consistently reload a6 from _bss+0 rather than using the caller's a6.

- **Non-canonical immediates**: several `movel #imm,dn` encodings are
  the long forms where `moveq` would do (`movel #12,d3`, `movel #12,d5`,
  `movel #0,d3`) — a compiler idiosyncrasy; each is emitted raw
  (`.short`/`.long`) to preserve the bytes.

- **Absolute-form calls**: some `jsr` targets are encoded as absolute
  (not PC-relative) and some EA forms use explicit zero-displacement
  modes; again raw-emitted to preserve encodings.

- **Conditional-branch idiom**: `_penmetric` uses `bles` where the
  semantically-similar sibling code uses `bls` — distinct encodings
  preserved verbatim.

- **BSS hunk carries the dependency base table**: rather than a data
  hunk, all nine OpenLibrary results + SysBase + scratch live in the
  152-byte zero-init hunk h2, addressed absolutely via `_bss+N`.
