---
type: Finding
title: Public vectors return in d3/d2
description: JoyDir returns in d3, JoyButtons in d2 — not the customary d0.
timestamp: 2026-10-10T18:00:00Z
---

# Public vectors return in d3/d2

Both public functions leave their result in d3 (direction) / d2
(buttons) and do not set d0 to the result (d0 holds the last
register read).  Callers must be custom (asm or register-asm C),
consistent with a private helper library for a game (the name
"fantasia" suggests a game project).  Reconstructed in
`source/fantasia_hw.s` verbatim, including unreachable `jmp`
tail-merges.  Minor deviation: gas encodes the tail jumps as
PC-relative `jmp` (4efa) rather than the original absolute form
(4ef9), and `move.l #n,d?` as `moveq` — same semantics, different
bytes.
