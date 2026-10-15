---
type: Library
title: hardblocks.library 1.1 - PACKED
description: >-
  Shipped binary is PowerPacker-compressed (PPLS magic); the
  underlying library is not directly hunk-readable.
timestamp: 2026-10-15T12:00:00Z
---

# hardblocks.library 1.1

The shipped file is a PowerPacker-packed binary (`PPLS` magic at
offset 0).  The real library image is the decrunched payload.

## Status

BLOCKED on depack - needs a PP20/PPLS decruncher applied to
binary/ first.  See findings.
