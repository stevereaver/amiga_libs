---
type: Structure
title: ContextNode (internal)
description: 40-byte context stack node.
resource: source/iffbase.h
timestamp: 2026-10-10T18:00:00Z
---

# ContextNode internals

Allocated 40 bytes with `AllocMem(40, 0)` on both the read path
(PushChunk scan) and the write path.  Layout:

| offset | field |
|-------:|-------|
| 0x00 | `struct MinNode cn_Node` — chain toward root |
| 0x08 | `LONG cn_ID` — chunk ID (root has 0) |
| 0x0c | `LONG cn_Type` — form type / context type |
| 0x10 | `LONG cn_Size` — declared chunk size (IFFSIZE_UNKNOWN=-1) |
| 0x14 | `LONG cn_Scan` — bytes consumed (public `cn_Scan`) |
| 0x18 | `struct MinList cn_LCIList` — local context items |
| 0x24 | `LONG cn_Used` — internal byte counter |

The stack lives on `iff_ContextStack`; `cn_Node` links downward to
the parent.  `FindPropContext`/`CurrentChunk`/`ParentChunk` walk it.
