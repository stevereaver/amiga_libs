---
type: Index
title: Findings
description: Quirks, API drift, open questions.
---

# Findings

- [ApiDrift](ApiDrift.md) — this 1.1 predates the v7 FD: 3-arg extsyms array, d0 bound, only 2 user functions
- [ErrorCodes](ErrorCodes.md) — even error numbers (-2,-10,-20,-30) vs the later odd set
- [OverCloseCheck](OverCloseCheck.md) — Close tests OpenCnt before decrementing
- [InitStyle](InitStyle.md) — non-AUTOINIT bootstrap; manual field init; spare base long
- [RebuildDeviations](RebuildDeviations.md) — what differs in the rebuilt binary
