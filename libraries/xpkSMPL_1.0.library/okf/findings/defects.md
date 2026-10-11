# Defects (faithfully reconstructed)

- **inlen==0 histogram wrap**: the `SUBQ #1/DBF` delta-histogram
  loop runs 65536 iterations for a zero-length input, then the
  sorted-list build dereferences an empty list -> NULL access.
  (same defect as 1.2)
- **output bound -17**: output cursor limited to `inlen/2` words;
  incompressible data reliably fails with -17. Same as 1.2.
- **len>=31 corrupt**: 4-bit lentab with the `>=15` 8-bit escape
  represents len only as `len-31` in a byte -- lengths >= 286 wrap,
  lengths 31+ silently lose the nibble marker semantics. Same as 1.2.
- **trie arena overflow**: up to 512 trie nodes share the same
  0x800-byte arena as... the arena is bounded but a pathological
  256-leaf codebook can need >512 internal nodes; unchecked. Same as 1.2.
- **+2 read past stream end**: the bit reader prefetches a word
  at every refill including the last. Same as 1.2.
- **uncleared AllocMem**: pack/unpack workmems use MEMF_ANY without
  MEMF_CLEAR; the histogram/table regions are explicitly cleared at
  use so the only effect is stale `xsp_Sub[0]`-adjacent data if the
  allocator returns a recycled block. Same as 1.2 (1.0 *does* clear
  Sub[0] on free -- the 1.1/1.2 stale-pointer defect is absent here).
