# Findings

- [OOBRunaway.md](OOBRunaway.md) — encoder reads past the input
  end on every iteration; a false 3-equal detect over the boundary
  can emit a run token past `srcend` and send the scan into an
  unbounded over-read/over-write.
- [RebuildDelta.md](RebuildDelta.md) — rebuild notes and deltas
  vs the shipped binary.
