---
type: Index
title: Findings
description: Quirks, deviations, open questions.
---

# Findings

- [NoVerCookie](NoVerCookie.md) — IdString has no "$VER:" prefix (1.5 fixed it)
- [TableLayout](TableLayout.md) — function table precedes the RomTag
- [UnconditionalDelexp](UnconditionalDelexp.md) — Expunge sets LIBF_DELEXP before the OpenCnt test
- [InitStubCall](InitStubCall.md) — LibInit calls its own null stub (dead check)
- [XpkInfoVersionZero](XpkInfoVersionZero.md) — xi_XpkInfoVersion = 0
- [EntryMinusOne](EntryMinusOne.md) — hunk entry returns -1, not 0
- [RebuildDeviations](RebuildDeviations.md) — what differs in the rebuilt binary
