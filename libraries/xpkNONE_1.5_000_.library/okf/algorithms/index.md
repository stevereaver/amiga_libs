---
type: Index
title: Algorithms
description: No compression algorithm — the packer is a raw store.
---

# Algorithms

None by design. "NONE" is the XPK identity/store packer:
[XpksUnpackChunk](../functions/XpksUnpackChunk.md) is a plain
`CopyMem`; packing is refused outright
([XpksPackChunk](../functions/XpksPackChunk.md)).
