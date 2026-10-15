---
type: Structures
title: utilities 1.2 layout
---

# Layout

- datasize 0x26 -> 34B node + 4B private.
- Resident+functab+InitTable all embedded in the DATA hunk tail
  (@0x308+); the functab's 26 entries relocate into hunk0.
- Message strings are Polish diagnostic templates for the
  string/number helpers.
