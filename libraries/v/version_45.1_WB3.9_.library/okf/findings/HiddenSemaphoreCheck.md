---
type: Finding
title: Hidden semaphore check routine
description: A FindSemaphore probe with an XOR-obfuscated name is exported through the library base, not the jump table.
---

# Hidden semaphore check routine

Since version 45.x (Workbench 3.5), version.library contains a
routine that is **not** an LVO: `LibInit` stores its address at
library-base +0x32 (`vb_Check`).  The routine XOR-deobfuscates a
10-byte semaphore name stored in the code hunk with a
caller-supplied key byte (d0), calls exec `FindSemaphore`
(`jsr -594(a6)`), re-obfuscates the buffer and returns the result.

Key observations:

- SysBase is fetched from **AbsExecBase (4.w)**, not from the
  saved `vb_SysBase` field — the routine does not depend on the
  base pointer in a6.
- The obfuscated bytes `42 c9 a0 b9 9b 8c 8f 9a c9 52` are
  identical across 44.2 / 45.1 / 45.5.
- The key is a parameter, so the plaintext name is not provable
  from the binary.  With key `0xE9` the bytes decode to the
  printable string `« IPrefs »` (guillemets in Amiga-1251) — a
  plausible intended semaphore name.
- **No caller exists inside this binary.**  Presumably external
  system components (SetPatch/IPrefs-era code) locate
  version.library's base and call `base+0x32` with a magic key —
  this is an anti-tamper / environment probe.  Exact caller and
  intended key remain an open question.

The reconstruction provides a byte-identical routine
(`source/version_check.s`, hand-written asm — required so the
10-byte name can live in the code hunk and be reached
pc-relative).
