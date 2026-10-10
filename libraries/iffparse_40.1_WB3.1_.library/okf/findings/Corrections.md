---
type: Finding
title: Corrections to earlier notes
description: Suspected inconsistencies that verification disproved.
timestamp: 2026-10-10T18:00:00Z
---

# Corrections

Two earlier readings of the binary were suspected inconsistencies;
closer inspection showed the binary is conventional in both cases.

## Hook dispatch field (+8 is h_Entry, not h_Data)

`CallHookEntry` calls the function pointer at hook offset +8.  With
`struct Hook` = MinNode(8) + h_Entry(4) + h_SubEntry(4) + h_Data(4),
offset +8 is `h_Entry` — the standard Amiga hook calling
convention, invoked with (a0=hook, a1=msg, a2=object).  No
inconsistency; an earlier note claiming `h_Data` was wrong.

## IOClipReq / ClipboardHandle sizes

The binary allocates a 120-byte ClipboardHandle and touches
io_Command@28, io_Offset@44, io_ClipID@48.  That is exactly the
standard NDK layout: `struct IOClipReq` is 52 bytes
(Message=20 + IORequest fields + 20 bytes of clip fields) and
`struct ClipboardHandle` is 52+34+34=120.  A hypothesised "legacy
6-byte-shifted" layout was unfounded; the reconstruction uses the
NDK structures directly.
