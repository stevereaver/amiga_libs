# Findings

- [OOBRunaway.md](OOBRunaway.md) — encoder reads past the input
  end on every iteration; a false 3-equal detect over the boundary
  can emit a run token past `srcend` and send the scan into an
  unbounded over-read/over-write.
- [RebuildDelta.md](RebuildDelta.md) — rebuild notes and deltas
  vs the shipped binary.
- [DeferredExpungeDefect.md](DeferredExpungeDefect.md) — Expunge
  writes LIBF_DELEXP on `a6` after reloading it with SysBase, so
  the bit lands on execbase+0xe; deferred expunge via Close is
  dead code.
