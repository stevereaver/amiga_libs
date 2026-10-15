---
type: Findings
title: sysinfo 1.30 quirks
---

# Findings / quirks

- Cross-hunk resident: rt_Name/rt_IdString point into hunk2,
  rt_Init into hunk1 — the Resident record lives in hunk0 but
  all three pointers cross hunks.
- Resident idstring 'Version 1.0' vs the real '$VER:' idstring
  'SysInfo.library 1.30 (22.11.95)' inside hunk0 — the RomTag
  idstring is a stub while the real $VER lives in code.
- -24 reserved vector is the hunk-start stub (0x0).
