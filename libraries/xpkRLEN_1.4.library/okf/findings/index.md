---
type: Index
title: Findings
description: Quirks, deviations, open questions.
---

# Findings

- [EntryMinusOne](EntryMinusOne.md) — hunk entry returns -1
- [MasterVersionZero](MasterVersionZero.md) — xi_MasterVersion = 0
- [DefPkInChunk4004](DefPkInChunk4004.md) — odd 0x4004 default chunk size
- [NullProgressMsgs](NullProgressMsgs.md) — all four progress strings NULL
- [LiteralReserve4](LiteralReserve4.md) — bounds check reserves 4 bytes for a 1-byte token
- [ReadPastEnd](ReadPastEnd.md) — encoder samples src[1]/src[2] past the input end
- [NoOutputBounds](NoOutputBounds.md) — decoder never checks OutBufLen
- [Decoder80](Decoder80.md) — code 0x80 emits the byte exactly once
- [UnusedBaseField](UnusedBaseField.md) — dataSize 0x2a, only SegList used
- [RebuildDeviations](RebuildDeviations.md) — what differs in the rebuilt binary
