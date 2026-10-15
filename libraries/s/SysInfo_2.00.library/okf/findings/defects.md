---
type: Findings
title: SysInfo.library 2.00 quirks
---

# Findings / quirks

- 3-hunk layout: InitTable in its own DATA hunk (at +4, after a
  dead zero long), functab + name/idstr strings in a trailing
  CODE hunk — same family as quickhelp 37.3.
- Shipped idstring is 't:SysInfo.library 2.0' — a literal 't:'
  prefix (t: is the Amiga temp assign; almost certainly a build
  slip baked into the shipped binary).
- hunk1+0x14 is a stray relocated long pointing one byte past
  the '$' of the code hunk's '$VER:' string.
- initfn (h0+0x20) opens no libraries; the Executive_server port
  work happens lazily in user vectors.
