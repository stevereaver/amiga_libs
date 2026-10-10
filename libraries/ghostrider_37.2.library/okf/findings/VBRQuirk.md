---
type: Finding
title: movec d4,vbr uses caller-supplied d4
---

# VBR write in GRCall6/GRCall7

The supervisor thunk (hunk+0x1b0, run via Exec Supervisor()
when AFF_68010 is set) executes `movec d4,vbr; rte` -- but d4
is **never loaded** by GhostRider's own code path.  It carries
whatever the caller of the LVO left in d4.

Two readings:

- Deliberate undocumented API: callers pass the desired vector
  base in d4 when invoking keys 6/7 (plausible -- the wrapper's
  Disable + VBR + CacheClearU sequence is exactly what a
  supervisor-mode vector relocation needs, and the launcher
  controls both sides).
- Bug: VBR gets set to garbage on 68010+ machines, which would
  misdirect all exceptions.

Either way the semantics are "VBR := caller's d4"; the
reconstruction reproduces this via the _GRSupervisor asm helper
in ghostrider_lib.s (.word-encoded `movec d4,vbr` to keep the
file 68000-clean).
