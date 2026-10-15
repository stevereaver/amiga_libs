---
type: Index
title: Findings
description: Defects and quirks found in the shipped binary.
timestamp: 2026-10-10T22:45:00Z
---

# Findings

- [EncoderDefects](EncoderDefects.md) — header overflow on
  129/130-byte literals, out-of-bounds input reads, possible
  invalid n=1 emit at input tail, 1-byte headroom check.
- [Quirks](Quirks.md) — entry returns -1, no $VER: cookie, no
  stream terminator, 2% ratio claim.
- [RebuildDelta](RebuildDelta.md) — byte-identical rebuild
  notes: descending RELOC32 tail, noncanonical AND/SUB-with-
  immediate encodings, asymmetric decoder biases, OutLen
  store tricks.
