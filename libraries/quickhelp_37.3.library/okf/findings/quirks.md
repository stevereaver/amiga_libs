---
type: Index
title: findings
timestamp: 2026-10-15T00:00:00Z
---

# Findings

- Mid-instruction branch: subs @hunk0+0x918/0x94c `beq` onto the
  immediate of a `cmpiw` (the imm `0x7000` executes as `moveq #0,d0`).
- Open clones the library data image per open and additively
  checksums the copy (constant ~0x10d9); initfn checksums hunk2's
  first 0x68 words similarly (0x12da).
- Functab lives in a separate 76B CODE hunk (hunk3) shared with the
  name/idstring strings; DATA hunk2 is a pure string table.
