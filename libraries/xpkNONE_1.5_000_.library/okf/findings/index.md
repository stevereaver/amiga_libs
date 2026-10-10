---
type: Index
title: Findings
description: Quirks, deviations, open questions.
---

# Findings

- [EntryStubReuse](EntryStubReuse.md) — entry `moveq #0/rts` doubles as RT_ENDSKIP target and the reserved-function vector
- [WordOffsetFunctab](WordOffsetFunctab.md) — -1-marker word-offset function table (vs. 1.4's absolute longs)
- [SysBaseAt4](SysBaseAt4.md) — ExecBase read from absolute 4.W; no xsb_SysBase field
- [DescriptorDiffs](DescriptorDiffs.md) — XpkInfo/XpkMode field differences vs. 1.4
- [RebuildDeviations](RebuildDeviations.md) — what differs in the rebuilt binary
